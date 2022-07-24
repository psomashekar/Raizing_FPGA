/*  This file is part of JTFRAME.
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
    Date: 7-7-2022 */

package main

import (
	//"text/template"
	"bytes"
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"text/template"
)

// appends arguments to a slice
func append_args(flag_name string, k *int, slice []string) []string {
	if *k < len(os.Args) && os.Args[*k] == flag_name {
		*k++
		added := 0
		for *k < len(os.Args) {
			if os.Args[*k][0] == '-' {
				*k--
				break
			}
			slice = append(slice, os.Args[*k])
			added++
			*k++
		}
		if added == 0 {
			log.Fatal("Expecting a macro name after ", flag_name)
		}
	}
	return slice
}

func parse_args() (cfg Config) {
	if len(os.Args) < 2 {
		fmt.Println("usage: jtcfgstr [-target (mist|mister|sidi|neptuno|mc2|mcp)] [-def path to def file] [-tpl path to template file]")
		os.Exit(1)
	}
	flag.StringVar(&cfg.target, "target", "mist", "Target platform (mist, mister, sidi, neptuno, mc2, mcp)")
	flag.StringVar(&cfg.deffile, "parse", "", "Path to .def file")
	flag.StringVar(&cfg.template, "tpl", "", "Path to template file")
	flag.StringVar(&cfg.commit, "commit", "nocommit", "Commit ID")
	flag.StringVar(&cfg.core, "core", "", "Core name, overrides -parse")
	flag.String("def", "", "Defines macro")
	flag.String("undef", "", "Undefines macro")
	flag.StringVar(&cfg.output, "output", "cfgstr",
		"Type of output: \n\tcfgstr -> config string\n\tbash -> bash script\n\tquartus -> quartus tcl\n\tverilator -> verilator command file")
	flag.BoolVar(&cfg.verbose, "v", false, "verbose")
	flag.Parse()
	switch cfg.target {
	case "mist", "mister", "sidi", "neptuno", "mc2", "mcp":
		break
	default:
		{
			fmt.Println("Unsupported target ", cfg.target)
			os.Exit(1)
		}
	}
	if len(cfg.core)>0 {
		cfg.deffile = filepath.Join( os.Getenv("CORES"), cfg.core, "/hdl/jt"+cfg.core+".def" )
	}
	if cfg.verbose {
		fmt.Println("target=", cfg.target)
		fmt.Println("def=", cfg.deffile)
	}
	for k := 1; k < len(os.Args); k++ {
		cfg.discard = append_args("-undef", &k, cfg.discard)
		cfg.add = append_args("-def", &k, cfg.add)
	}
	return
}

func make_cfgstr(cfg Config, def map[string]string) (cfgstr string) {
	jtframe_path := os.Getenv("JTFRAME")
	if jtframe_path == "" {
		log.Fatal("Environment variable JTFRAME must be set")
	}
	var tpath string
	if cfg.template == "" {
		tfolder := cfg.target
		if cfg.target == "sidi" { // SiDi shares the config string with MiST
			tfolder = "mist"
		}
		tpath = jtframe_path + "/target/" + tfolder + "/cfgstr"
	} else {
		tpath = cfg.template
	}
	t := template.Must(template.ParseFiles(tpath))
	var buffer bytes.Buffer
	t.Execute(&buffer, def)
	cfgstr = buffer.String()
	// Trim spaces
	chunks := strings.Split(cfgstr, ";")
	cfgstr = ""
	for _, s := range chunks {
		cfgstr = cfgstr + strings.TrimSpace(s) + ";"
	}
	// Removes any ; at the end
	for len(cfgstr) > 0 && cfgstr[len(cfgstr)-1] == ';' {
		cfgstr = cfgstr[0 : len(cfgstr)-1]
	}
	return
}

func dump_cfgstr(cfgstr string) {
	f, err := os.Create("cfgstr.hex")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()
	for k, c := range cfgstr {
		fmt.Fprintf(f, "%02X ", c)
		if k&0xf == 0xf {
			fmt.Fprintln(f, "")
		}
	}
	for k := len(cfgstr); k < 1024; k++ {
		fmt.Fprintf(f, "00 ")
		if k&0xf == 0xf {
			fmt.Fprintln(f, "")
		}
	}
}

func dump_bash(def map[string]string) {
	for k, v := range def {
		fmt.Printf("export %s=\"%s\"\n", k, v)
	}
}

func dump_cpp(def map[string]string) {
	for k, v := range def {
		if k == "JTFRAME_GAMEPLL" {
			v = "\"" + v + "\""
		}
		fmt.Printf("#define %s %s\n", k, v)
	}
}

func dump_verilog(def map[string]string, fmtstr string, esc_quotes bool) {
	for k, v := range def {
		if len(v) > 2 && v[0:2] == "0x" {
			val, _ := strconv.ParseInt(v, 0, 0)
			v = fmt.Sprintf("'h%X", val)
		}
        // Optionally escape quote characters
        if esc_quotes {
            v = strings.ReplaceAll( v, "\"", "\\\"" )
        }
		// Output the key=value pair in the format
		// given by fmtstr, but skip it if the value
		// contains spaces, as simulators will get
		// confused
		if strings.Index(v, " ") == -1 {
			fmt.Printf(fmtstr+"\n", k, v)
		}
	}
}

func dump_parameter(def map[string]string, fmtstr string) {
	for k, v := range def {
		if !strings.HasPrefix(k,"JTFRAME_") {
			continue
		}
		if len(v)==0 {
			v="1"
		}
		if len(v) > 2 && v[0:2] == "0x" {
			val, _ := strconv.ParseInt(v, 0, 0)
			v = fmt.Sprintf("'h%X", val)
		}
		// Output the key=value pair in the format
		// given by fmtstr, but skip it if the value
		// contains spaces, as simulators will get
		// confused
		if strings.Index(v, " ") == -1 {
			fmt.Printf(fmtstr+"\n", k, v)
		}
	}
}

func main() {
	cfg := parse_args()
	def := Make_macros(cfg)
	if !Check_macros(def) {
		os.Exit(1)
	}
	switch cfg.output {
	case "cfgstr":
		{
			// Make the config string
			cfgstr := make_cfgstr(cfg, def)
			dump_cfgstr(cfgstr)
			// show the config string
			if cfg.verbose {
				fmt.Printf("Config for target %s (%d bits)\n\n", cfg.target, len(cfgstr)*8)
				fmt.Println(cfgstr, "\n\nBreak up:")
				aux := strings.Split(cfgstr, ";")
				for _, s := range aux {
					fmt.Println("\t", s)
				}
			}
		}
	case "cpp":
		dump_cpp(def)
	case "bash":
		dump_bash(def)
	case "quartus":
		dump_verilog(def, "set_global_assignment -name VERILOG_MACRO \"%s=%s\"",false)
		// dump_parameter(def, "set_parameter -name %s %s")
	case "iverilog", "verilator":
		dump_verilog(def, "+define+%s=%s",false)
    case "ncverilog":
        dump_verilog(def, "+define+%s=%s",true)
	default:
		{
			fmt.Println("Error: specified output is not valid: ", cfg.output)
			os.Exit(1)
		}
	}
}
