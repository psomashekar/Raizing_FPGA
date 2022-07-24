/*  This file is part of JT_FRAME.
    JTFRAME program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JTFRAME program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JTFRAME.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 9-5-2022 */

#include <cstring>
#include <iostream>
#include <fstream>
#include "UUT.h"
#include "defmacros.h"

// fork
#include <sys/types.h>
#include <unistd.h>

#ifdef DUMP
    #include "verilated_vcd_c.h"
#endif

#ifndef DUMP_START
    const int DUMP_START=0;
#endif

#ifndef JTFRAME_COLORW
    #define JTFRAME_COLORW 4
#endif

#ifdef JTFRAME_CLK96
    const bool USE_CLK96=true;
#else
    const bool USE_CLK96=false;
#endif

#ifndef JTFRAME_GAMEPLL
    #define JTFRAME_GAMEPLL "jtframe_pll6000"
#endif

using namespace std;

#ifdef JTFRAME_SDRAM_LARGE
    const int BANK_LEN = 0x100'0000;
#else
    const int BANK_LEN = 0x080'0000;
#endif

#ifndef JTFRAME_SIM_DIPS
    #define JTFRAME_SIM_DIPS 0xffffffff
#endif

class WaveWritter {
    std::ofstream fsnd, fhex;
    std::string name;
    bool dump_hex;
    void Constructor(const char *filename, int sample_rate, bool hex );
public:
    WaveWritter(const char *filename, int sample_rate, bool hex ) {
        Constructor( filename, sample_rate, hex );
    }
    WaveWritter(const std::string &filename, int sample_rate, bool hex ) {
        Constructor( filename.c_str(), sample_rate, hex );
    }
    void write( int16_t *lr );
    ~WaveWritter();
};

class SDRAM {
    UUT& dut;
    char *banks[4];
    int rd_st[4];
    int ba_addr[4];
    //int last_rd[5];
    char header[32];
    int burst_len, burst_mask;
    int read_offset( int region );
    int read_bank( char *bank, int addr );
    void write_bank16( char *bank,  int addr, int val, int dm /* act. low */ );
public:
    SDRAM(UUT& _dut);
    ~SDRAM();
    void update();
    void dump();
};

class SimInputs {
    ifstream fin;
    UUT& dut;
    int line;
    bool done;
public:
    SimInputs( UUT& _dut) : dut(_dut) {
        dut.dip_pause=1;
        dut.joystick1 = 0xff;
        dut.joystick2 = 0xff;
        dut.start_button = 0xf;
        dut.coin_input   = 0xf;
        dut.service      = 1;
        dut.dip_test     = 1;
#ifdef SIM_INPUTS
        line = 0;
        done = false;
        fin.open("sim_inputs.hex");
        if( fin.bad() ) {
            cout << "Error: could not open sim_inputs.hex\n";
        } else {
            cout << "reading sim_inputs.hex\n";
        }
        next();
#else
        done = true;
#endif
    }
    void next() {
        if( !done && fin.good() ) {
            string s;
            unsigned v;
            ++line;
            getline( fin, s );
            sscanf( s.c_str(),"%x", &v );
            v = ~v;
            auto coin_l  = dut.coin_input&3;
            dut.start_button = 0xc | ((v>>2)&3);
            dut.coin_input   = 0xc | (v&3);
            dut.joystick1    = 0x3c0 | ((v>>4)&0x3f);
            if( coin_l != (dut.coin_input&3) && coin_l!=3 ) {
                cout << "\ncoin inserted (line " << line << ")\n";
            }
            if( fin.eof() ) {
                done = true;
                cout << "\nsim_inputs.hex finished at line " << line << endl;
                fin.close();
            }
        } else {
            dut.start_button = 0xf;
            dut.coin_input   = 0xf;
            dut.joystick1    = 0x3ff;
        }
    }
};

class Download {
    UUT& dut;
    int addr, din, ticks,len;
    char *buf;
    bool done, full_download;
    int read_buf() {
        return (buf!=nullptr && addr<len) ? buf[addr] : 0;
    }
public:
    Download(UUT& _dut) : dut(_dut) {
        done = false;
        buf = nullptr;
        ifstream fin( "rom.bin", ios_base::binary );
        fin.seekg( 0, ios_base::end );
        len = (int)fin.tellg();
        if( len == 0 || fin.bad() ) {
            cout << "Verilator test.cpp: cannot open file rom.bin" << endl;
        } else {
            buf = new char[len];
            fin.seekg(0, ios_base::beg);
            fin.read(buf,len);
            if( fin.bad() ) {
                cout << "Verilator test.cpp: problem while reading rom.bin" << endl;
            } else {
                cout << "Read " << len << " bytes from rom.bin" << endl;
            }
        }
    };
    ~Download() {
        delete []buf;
        buf=nullptr;
    };
    bool FullDownload() { return full_download; }
    void start( bool download ) {
        full_download = download; // At least the first 32 bytes will always be downloaded
        if( !full_download ) {
            if ( len > 32 ) {
                cout << "ROM download shortened to 32 bytes\n";
                len=32;
            } else {
                cout << "Short ROM download\n";
            }
        }
        ticks = 0;
        done = false;
        dut.downloading = 1;
        dut.ioctl_addr = 0;
        dut.ioctl_dout = read_buf();
        dut.ioctl_wr   = 0;
        addr = -1;
    }
    void update() {
        dut.ioctl_wr = 0;
        if( !done && dut.downloading ) {
            switch( ticks & 15 ) { // ~ 12 MBytes/s - at 6MHz jtframe_sdram64 misses writes
                case 0:
                    addr++;
                    dut.ioctl_addr = addr;
                    dut.ioctl_dout = read_buf();
                    break;
                case 1:
                    if( addr < len ) {
                        dut.ioctl_wr = 1;
                    } else {
                        dut.downloading = 0;
                        done = true;
                        cout << "ROM file transfered\n";
                    }
                    break;
            }
            ticks++;
        } else {
            ticks=0;
        }
    }
};

const int VIDEO_BUFLEN = JTFRAME_WIDTH*JTFRAME_HEIGHT;

class JTSim {
    vluint64_t simtime;
    vluint64_t semi_period;
    WaveWritter wav;

    void parse_args( int argc, char *argv[] );
    void video_dump();
    bool trace;   // trace enable or not
    bool dump_ok; // can we dump? (provided trace is enabled)
    bool download;
    VerilatedVcdC* tracer;
    SDRAM sdram;
    SimInputs sim_inputs;
    Download dwn;
    int frame_cnt, last_VS;
    // Video dump
    struct t_dump{
        ofstream fout;
        int k;
        int32_t buffer0[VIDEO_BUFLEN];
        int32_t *buffer;
        void reset() {
            buffer = buffer0;
            k = 0;
        }
        t_dump() {
            reset();
        }
        void push(int32_t val) {
            if( k<VIDEO_BUFLEN ) {
                *buffer++ = val;
                k++;
            }
        }
    } dump;
    int color8(int c) {
        switch(JTFRAME_COLORW) {
            case 8: return c;
            case 5: return (c<<3) | ((c>>2)&3);
            case 4: return (c<<4) | c;
            default: return c;
        }
    }
    void reset(int r);
public:
    int finish_time, finish_frame, totalh, totalw, activeh, activew;
    bool done() {
        return (finish_frame>0 ? frame_cnt > finish_frame :
                simtime/1000'000'000 >= finish_time ) && (!game.downloading && !game.dwnld_busy);
    };
    UUT& game;
    int get_frame() { return frame_cnt; }
    void update_wav();
    JTSim( UUT& g, int argc, char *argv[] );
    ~JTSim();
    void clock(int n);
};

////////////////////////////////////////////////////////////////////////
//////////////////////// SDRAM /////////////////////////////////////////


int SDRAM::read_bank( char *bank, int addr ) {
    const int mask = (BANK_LEN>>1)-1; // 8/16MB in 16-bit words
    addr &= mask;
    int16_t *b16 =(int16_t*)bank;
    int v = b16[addr]&0xffff;
    //printf("\tread %x\n", addr );
    return v;
}

void SDRAM::write_bank16( char *bank, int addr, int val, int dm /* act. low */ ) {
    const int mask = (BANK_LEN>>1)-1; // 8/16MB in 16-bit words
    addr &= mask;
    int16_t *b16 =(int16_t*)bank;

    int v = (int)b16[addr];
    if( (dm&1) == 0 ) {
        v &= 0xff00;
        v |= val&0xff;
    }
    if( (dm&2) == 0 ) {
        v &= 0xff;
        v |= val&0xff00;
    }
    v &= 0xffff;
    b16[addr] = (int16_t)v;
    //if(verbose) printf("%04X written to %X\n", v,addr);
}

void SDRAM::dump() {
    char *aux=new char[BANK_LEN];
    for( int k=0; k<4; k++ ) {
        char fname[32];
        sprintf(fname,"sdram_bank%d.bin",k);
        ofstream fout(fname,ios_base::binary);
        if( !fout.good() ) {
            cout << "Error creating " << fname << '\n';
        }
        // reverse bytes because 16-bit access operation
        // use the wrong endianness in intel machines
        // this makes the dump compatible with other verilog simulators
        for( int j=0;j<BANK_LEN;j++) {
            aux[j^1] = banks[k][j];
        }
        fout.write(aux,BANK_LEN);
        if( !fout.good() ) {
            cout << "Error saving to " << fname << '\n';
        }
        cout << fname << " dumped\n";
#ifndef JTFRAME_SDRAM_BANKS
        break;
#endif
    }
    delete[] aux;
}

void SDRAM::update() {
    static auto last_clk = dut.SDRAM_CLK;
    bool neg_edge = !dut.SDRAM_CLK && last_clk;
    int cur_ba = dut.SDRAM_BA;
    cur_ba &= 3;
    if( !dut.SDRAM_nCS && neg_edge ) {
        if( !dut.SDRAM_nRAS && !dut.SDRAM_nCAS && !dut.SDRAM_nWE ) { // Mode register
            int mode = dut.SDRAM_A;
            burst_len = 1 << (mode&3);
            burst_mask = ~(burst_len-1);
            cout << "SDRAM burst mode changed to " << burst_len << " mask 0x" << hex << burst_mask << '\n';
            if( burst_len>4 ) {
                throw "\nError: support for bursts larger than 4 is not implemented in test.cpp\n";
            }
        }
        if( !dut.SDRAM_nRAS && dut.SDRAM_nCAS && dut.SDRAM_nWE ) { // Row address - Activate command
            ba_addr[ cur_ba ] = dut.SDRAM_A << 9; // 32MB module
            ba_addr[ cur_ba ] &= 0x3fffff;
        }
        if( dut.SDRAM_nRAS && !dut.SDRAM_nCAS ) {
            ba_addr[ cur_ba ] &= ~0x1ff;
            ba_addr[ cur_ba ] |= (dut.SDRAM_A & 0x1ff);
            if( dut.SDRAM_nWE ) { // enque read
                rd_st[ cur_ba ] = burst_len+1;
            } else {
                int dqm = dut.SDRAM_DQM;
                // cout << "Write bank " << cur_ba <<
                //         " ADDR = " << std::hex << ba_addr[cur_ba] <<
                //         " DATA = " << dut.SDRAM_DIN << " Mask = " << dqm << std::dec<< '\n';
                write_bank16( banks[cur_ba], ba_addr[cur_ba], dut.SDRAM_DIN, dqm );
            }
        }
        bool dqbusy=false;
        for( int k=0; k<4; k++ ) {
            // switch( k ) {
            //  case 0: dut.SDRAM_BA_ADDR0 = ba_addr[0]; break;
            //  case 1: dut.SDRAM_BA_ADDR1 = ba_addr[1]; break;
            //  case 2: dut.SDRAM_BA_ADDR2 = ba_addr[2]; break;
            //  case 3: dut.SDRAM_BA_ADDR3 = ba_addr[3]; break;
            // }
            if( rd_st[k]>0 && rd_st[k]<=burst_len ) { // Supports only 32-bit reads
                if( dqbusy ) {
                    cout << "WARNING: SDRAM reads clashed\n";
                }
                // if( rd_st[k]==burst_len ) printf("Read start\n");
                auto data_read = read_bank( banks[k], ba_addr[k] );
                //cout << "Read " << std::hex << data_read << " from bank " << k << '\n';
                dut.SDRAM_DQ = data_read;
                if( burst_len>1 ) {
                    // Increase the column within the burst
                    auto col = ba_addr[k]&0x1ff;
                    auto col_inc = (col+1) & ~burst_mask;
                    col &= burst_mask;
                    col |= col_inc;
                    ba_addr[k] &= ~0x1ff;
                    ba_addr[k] |= col;
                }
                dqbusy = true;
            }
            if(rd_st[k]>0) rd_st[k]--;
        }
    }
    last_clk = dut.SDRAM_CLK;
}


int SDRAM::read_offset( int region ) {
    if( region>=32 ) {
        region = 0;
        printf("ERROR: tried to read past the header\n");
        return 0;
    }
    int offset = (((int)header[region]<<8) | ((int)header[region+1]&0xff)) & 0xffff;
    return offset<<8;
}

SDRAM::SDRAM(UUT& _dut) : dut(_dut) {
#ifdef JTFRAME_SDRAM_BANKS
    cout << "Multibank SDRAM enabled\n";
#endif
    banks[0] = nullptr;
    burst_len= 1;
    for( int k=0; k<4; k++ ) {
        banks[k] = new char[BANK_LEN];
        rd_st[k]=0;
        ba_addr[k]=0;
        // delete the content
        memset( banks[k], 0, BANK_LEN );
        // Try to load a file for it
        char fname[32];
        sprintf(fname,"sdram_bank%d.bin",k);
        ifstream fin( fname, ios_base::binary );
        if( fin ) {
            fin.seekg( 0, fin.end );
            auto len = fin.tellg();
            fin.seekg( 0, fin.beg );
            if( len>BANK_LEN ) len=BANK_LEN;
            char *aux=new char[BANK_LEN];
            fin.read( aux, len );
            auto pos = fin.tellg();
            cout << "Read " << hex << pos << " from " << fname << '\n';
            // reverse the byte order
            for( int j=0;j<pos;j++) {
                banks[k][j] = aux[j^1];
            }
            delete []aux;
            // Reset the rest of the SDRAM bank
            if( pos<BANK_LEN )
                memset( (void*)&banks[k][pos], 0, BANK_LEN-pos);
        } else {
            cout << "Skipped " << fname << "\n";
        }
    }
}

SDRAM::~SDRAM() {
    for( int k=0; k<4; k++ ) {
        delete [] banks[k];
        banks[k] = nullptr;
    }
}

////////////////////////////////////////////////////////////////////////
//////////////////////// JTSIM /////////////////////////////////////////

void JTSim::reset( int v ) {
    game.rst = v;
#ifdef JTFRAME_CLK96
    game.rst96 = v;
#endif
#ifdef JTFRAME_CLK24
    game.rst24 = v;
#endif
}

JTSim::JTSim( UUT& g, int argc, char *argv[]) :
    game(g), sdram(g), dwn(g), sim_inputs(g), wav("snd.wav",48000,false)
{
    simtime=0;
    frame_cnt=0;
    last_VS = 0;
    // Derive the clock speed from JTFRAME_GAMEPLL
    const char *jtframe_gamepll = JTFRAME_GAMEPLL;
    if( strlen(jtframe_gamepll)!=strlen("jtframe_pll6000") ) {
        throw ( "Error: JTFRAME_GAMEPLL malformed. It must be like jtframe_pll6000\n"
            "where the last four digits represent the clock frequency in kHz\n" );
    }
    float freqkHz = atof(jtframe_gamepll+11);
    if( freqkHz < 5500.0 || freqkHz>9000.0 ) {
        throw("Error: unexpected JTFRAME_GAMEPLL value\n");
    }
    semi_period = 0.5e9/8.0/freqkHz;
    cout << "Simulation clock period set to " << dec << (semi_period<<1) << "ps\n";
#ifdef LOADROM
    download = true;
#else
    download = false;
#endif
    parse_args( argc, argv );
#ifdef DUMP
    if( trace ) {
        Verilated::traceEverOn(true);
        tracer = new VerilatedVcdC;
        game.trace( tracer, 99 );
        tracer->open("test.vcd");
        cout << "Verilator will dump to test.vcd\n";
    } else {
        tracer = nullptr;
    }
#endif
#ifdef JTFRAME_SIM_GFXEN
    game.gfx_en=JTFRAME_SIM_GFXEN;    // enable selected layers
#else
    game.gfx_en=0xf;    // enable all layers
#endif
    game.dipsw=JTFRAME_SIM_DIPS;
    reset(0);
    game.sdram_rst = 0;
    clock(48);
    game.sdram_rst = 1;
    reset(1);
    clock(48);
    game.sdram_rst = 0;
#ifdef JTFRAME_CLK96
    game.rst96 = 0;
#endif
    clock(10);
    // Wait for the SDRAM initialization
    for( int k=0; k<1000 && game.sdram_init==1; k++ ) clock(1000);
    // Download the game ROM
    dwn.start(download);
}

JTSim::~JTSim() {
#ifdef DUMP
    delete tracer;
#endif
}

void JTSim::clock(int n) {
    static int ticks=0;
    static int last_dwnd=0;
    while( n-- > 0 ) {
        int cur_dwn = game.downloading | game.dwnld_busy;
        game.clk = 1;
#ifdef JTFRAME_CLK24    // not supported together with JTFRAME_CLK96
        game.clk24 = ticks&1;
#endif
#ifdef JTFRAME_CLK48
        game.clk48 = 1-game.clk48;
#endif
#ifdef JTFRAME_CLK96
        game.clk96 = game.clk;
#endif
        game.eval();
        sdram.update();
        dwn.update();
        if( !cur_dwn && last_dwnd ) {
            // Download finished
            if( finish_time>0 ) finish_time += simtime/1000'000'000;
            if( finish_frame>0 ) finish_frame += frame_cnt;
            if ( dwn.FullDownload() ) sdram.dump();
            reset(0);
        }
        last_dwnd = cur_dwn;
        simtime += semi_period;
#ifdef DUMP
        if( tracer && dump_ok ) tracer->dump(simtime);
#endif
        game.clk = 0;
#ifdef JTFRAME_CLK96
        game.clk96 = game.clk;
#endif
        game.eval();
        sdram.update();
        simtime += semi_period;
        ticks++;

#ifdef DUMP
        if( tracer && dump_ok ) tracer->dump(simtime);
#endif
        // frame counter & inputs
        if( game.VS && !last_VS ) {
            frame_cnt++;
            if( frame_cnt == DUMP_START && !dump_ok ) {
                dump_ok = 1;
                cout << "\nDump starts " << dec << frame_cnt << '\n';
            }
            cout << ".";
            if( !(frame_cnt & 0x3f) ) cout << '\n';
            cout.flush();
            sim_inputs.next();
        }
        last_VS = game.VS;

        // Video dump
        video_dump();
    }
}

void JTSim::video_dump() {
    static int LHBLl, LVBLl;
    static int cntw[2], cnth[2];
    if( game.pxl_cen ) {
        // Dump the video
        if( game.LHBL && game.LVBL && frame_cnt>0 ) {
            const int MASK = (1<<JTFRAME_COLORW)-1;
            int red   = game.red   & MASK;
            int green = game.green & MASK;
            int blue  = game.blue  & MASK;
            int mix = 0xFF000000 |
                ( color8(blue ) << 16 ) |
                ( color8(green) <<  8 ) |
                ( color8(red  )       );
            dump.push( mix );
        }
        // Count the video size
        if( !game.LHBL && LHBLl!=0 ) {
            totalw = cntw[0];
            activew= cntw[1];
            cntw[0]=0; cntw[1]=0;
            if( !game.LVBL && LVBLl!=0 ) {
                totalh = cnth[0];
                activeh= cnth[1];
                cnth[0]=0; cnth[1]=0;
                dump.reset();
                // converts image to jpg in a different fork
                // I suppose a thread would be faster...
                if( fork()==0 ) {
                    dump.fout.open("frame.raw",ios_base::binary);
                    if( dump.fout.good() ) {
                        dump.fout.write( (char*)dump.buffer, (activew*activeh)<<2 );
                        dump.fout.close();
                        char exes[512];
                        sprintf(exes,"convert -filter Point "
                            "-size %dx%d -depth 8 RGBA:frame.raw frame_%d.jpg",
                            activew, activeh, frame_cnt);
                        system(exes);
                    }
                    exit(0);
                }
            } else {
                cnth[0]++;
                if( game.LVBL!=0 ) cnth[1]++;
            }
            LVBLl = game.LVBL;
        } else {
            cntw[0]++;
            if( game.LHBL!=0 ) cntw[1]++;
        }
        LHBLl = game.LHBL;
    }
}

void JTSim::update_wav() {
    int16_t snd[2];
    snd[0] = game.snd_left;
    snd[1] = game.snd_right;
    wav.write(snd);
}

void JTSim::parse_args( int argc, char *argv[] ) {
    trace = false;
    finish_frame = -1;
    finish_time  = 10;
    for( int k=1; k<argc; k++ ) {
        if( strcmp( argv[k], "--trace")==0 ) {
            trace=true;
            dump_ok = DUMP_START==0;
            continue;
        }
        if( strcmp( argv[k], "-time")==0 ) {
            if( ++k >= argc ) {
                cout << "ERROR: expecting time after -time argument\n";
            } else {
                finish_time = atol(argv[k]);
            }
            continue;
        }
        if( strcmp( argv[k], "-frame")==0 ) {
            if( ++k >= argc ) {
                cout << "ERROR: expecting frame count after -frame argument\n";
            } else {
                finish_frame = atol(argv[k]);
            }
            continue;
        }
    }
    #ifdef MAXFRAME
    finish_frame = MAXFRAME;
    #endif
}

void WaveWritter::write( int16_t* lr ) {
    fsnd.write( (char*)lr, sizeof(int16_t)*2 );
    if( dump_hex ) {
        fhex << hex << lr[0] << '\n';
        fhex << hex << lr[1] << '\n';
    }
}

void WaveWritter::Constructor( const char *filename, int sample_rate, bool hex ) {
    name = filename;
    fsnd.open(filename, ios_base::binary);
    dump_hex = hex;
    if( dump_hex ) {
        char *hexname;
        hexname = new char[strlen(filename)+1];
        strcpy(hexname,filename);
        strcpy( hexname+strlen(filename)-4, ".hex" );
        cerr << "Hex file " << hexname << '\n';
        fhex.open(hexname);
        delete[] hexname;
    }
    // write header
    char zero=0;
    for( int k=0; k<45; k++ ) fsnd.write( &zero, 1 );
    fsnd.seekp(0);
    fsnd.write( "RIFF", 4 );
    fsnd.seekp(8);
    fsnd.write( "WAVEfmt ", 8 );
    int32_t number32 = 16;
    fsnd.write( (char*)&number32, 4 );
    int16_t number16 = 1;
    fsnd.write( (char*) &number16, 2);
    number16=2;
    fsnd.write( (char*) &number16, 2);
    number32 = sample_rate;
    fsnd.write( (char*)&number32, 4 );
    number32 = sample_rate*2*2;
    fsnd.write( (char*)&number32, 4 );
    number16=2*2;   // Block align
    fsnd.write( (char*) &number16, 2);
    number16=16;
    fsnd.write( (char*) &number16, 2);
    fsnd.write( "data", 4 );
    fsnd.seekp(44);
}

WaveWritter::~WaveWritter() {
    int32_t number32;
    streampos file_length = fsnd.tellp();
    number32 = (int32_t)file_length-8;
    fsnd.seekp(4);
    fsnd.write( (char*)&number32, 4);
    fsnd.seekp(40);
    number32 = (int32_t)file_length-44;
    fsnd.write( (char*)&number32, 4);
}


////////////////////////////////////////////////////
// Main

int main(int argc, char *argv[]) {
    Verilated::commandArgs(argc, argv);

    cout << "Verilator sim starts\n";
    try {
        UUT game;
        JTSim sim(game, argc, argv);

        while( !sim.done() ) {
            sim.clock(1'000); // if the clock is 48MHz, this will dump at 48kHz
            sim.update_wav(); // Other clock rates will not have exact wav dumps
            if( sim.get_frame()==2 ) {
                if( sim.activeh != JTFRAME_HEIGHT || sim.activew != JTFRAME_WIDTH ) {
                    printf("\nError: video size mismatch. Macros define it as %dx%d but the core outputs %dx%d\n",
                        JTFRAME_WIDTH, JTFRAME_HEIGHT, sim.activew, sim.activeh );
                    break;
                }
            }
        }
        if( sim.get_frame()>1 ) cout << endl;
    } catch( const char *error ) {
        cout << error << endl;
        return 1;
    }
    return 0;
}