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
	"bufio"
	"fmt"
	"log"
	"os"
	"path"
	"strconv"
	"strings"
	"time"
)

type Config struct {
	target,
	deffile,
	template,
	output,
	core,
	commit string
	add     []string // new definitions in command line
	discard []string // definitions to be discarded
	verbose bool
}

func parse_def(path string, cfg Config, macros *map[string]string) {
	if path == "" {
		return
	}
	f, err := os.Open(path)
	if err != nil {
		log.Fatal("Cannot open " + path)
	}
	defer f.Close()
	scanner := bufio.NewScanner(f)
	scanner.Split(bufio.ScanLines)
	section := "all"
	linecnt := 0

	for scanner.Scan() {
		linecnt++
		line := strings.TrimSpace(scanner.Text())
		if len(line) == 0 || line[0] == '#' {
			continue
		}
		if line[0] == '[' {
			idx := strings.Index(line, "]")
			if idx == -1 {
				fmt.Println("Malformed expression at line ", linecnt, " of file ", path)
				log.Fatal("Bad def file")
			}
			sections := strings.Split(strings.TrimSpace(line[1:idx]), "|")
			for _, s := range sections {
				section = s
				if strings.TrimSpace(s) == cfg.target {
					break
				}
			}
			continue
		}
		if section == "all" || section == cfg.target {
			// Look for keywords
			words := strings.SplitN(line, " ", 2)
			if words[0] == "include" {
				// Include files are relative to the calling file,
				// unless they start with /
				slash := strings.LastIndex(path, "/")
				inc := words[1]
				if slash != -1 && inc[0] != '/' {
					inc = path[0:slash+1] + inc
				}
				parse_def(inc, cfg, macros)
				continue
			}
			words = strings.SplitN(line, "=", 2)
			key := strings.ToUpper(strings.TrimSpace(words[0]))
			if key[0] == '-' {
				// Removes key
				key = key[1:]
				delete(*macros, key)
			} else {
				if len(words) > 1 {
					val := strings.TrimSpace(words[1])
					if len(key) > 2 && key[len(key)-1] == '+' {
						key = key[0 : len(key)-1]
						old, e := (*macros)[key]
						if e {
							val = old + val
						}
					}
					(*macros)[key] = val
				} else {
					(*macros)[key] = "1"
				}
			}
		}
	}
	return
}

// check incompatible macro settings
func Check_macros(def map[string]string) bool {
	// Check that MiST DIPs are defined after the
	// last used status bit
	dipbase, _ := strconv.Atoi(def["JTFRAME_MIST_DIPBASE"])
	if def["JTFRAME_MIST_DIPBASE"] == "" {
		dipbase = 16
	}
	_, autofire0 := def["JTFRAME_AUTOFIRE0"]
	_, osd_snd_en := def["JTFRAME_OSD_SND_EN"]
	_, osd_test := def["JTFRAME_OSD_TEST"]
	if autofire0 && dipbase < 17 {
		log.Fatal("MiST DIP base is smaller than the required value by JTFRAME_AUTOFIRE0")
		return false
	}
	if osd_snd_en && dipbase < 10 {
		log.Fatal("MiST DIP base is smaller than the required value by JTFRAME_OSD_SND_EN")
		return false
	}
	if osd_test && dipbase < 11 {
		log.Fatal("MiST DIP base is smaller than the required value by JTFRAME_OSD_TEST")
		return false
	}
	return true
}

func get_defpath(cfg Config) string {
	jtroot := os.Getenv("JTROOT")
	if cfg.core != "" && jtroot != "" {
		path := path.Join(jtroot, "cores", cfg.core, "hdl", "jt"+cfg.core+".def")
		return path
	} else {
		return cfg.deffile
	}
}

func Make_macros(cfg Config) (macros map[string]string) {
	macros = make(map[string]string)
	parse_def(get_defpath(cfg), cfg, &macros)
	switch cfg.target {
	case "mist", "sidi", "neptuno":
		macros["SEPARATOR"] = ""
	case "mister":
		macros["SEPARATOR"] = "-;"
	}
	macros["TARGET"] = cfg.target
	// Adds the date
	year, month, day := time.Now().Date()
	datestr := fmt.Sprintf("%d%02d%02d", year%100, month, day)
	macros["DATE"] = datestr
	// Adds the commit
	macros["COMMIT"] = cfg.commit
	// Adds the timestamp
	macros["JTFRAME_TIMESTAMP"] = fmt.Sprintf("%d", time.Now().Unix())
	// prevent the CORE_OSD from having two ;; in a row or starting with ;
	core_osd := macros["CORE_OSD"]
	if len(core_osd) > 0 {
		if core_osd[0] == ';' {
			core_osd = core_osd[1:]
		}
		core_osd = strings.ReplaceAll(core_osd, ";;", ";")
		if core_osd[len(core_osd)-1] != ';' {
			core_osd = core_osd + ";"
		}
		macros["CORE_OSD"] = core_osd
	} else {
		macros["CORE_OSD"] = ""
	}
	// Delete macros listed in cfg.discard
	for _, undef := range cfg.discard {
		delete(macros, undef)
	}
	// Add macros in cfg.add
	for _, def := range cfg.add {
		split := strings.SplitN(def, "=", 2)
		if len(split) == 2 {
			macros[split[0]] = split[1]
		} else {
			macros[split[0]] = "1"
		}
	}
	// JTFRAME_PLL is defined as the PLL name
	// in the .def file. This will define that
	// name as a macro on its own too
	if pll, e := macros["JTFRAME_PLL"]; e {
		macros[strings.ToUpper(pll)] = ""
	}
	// if the macro BETA is defined, and we are on MiSTer, make
	// sure JTFRAME_CHEAT is defined too
	_, isbeta := macros["BETA"]
	if isbeta {
		_, cheatok := macros["JTFRAME_CHEAT"]
		if !cheatok && cfg.target == "mister" {
			fmt.Fprintln(os.Stderr, "Compiling a BETA for MiSTer but JTFRAME_CHEAT was not set\nAdding it now automatically.")
			macros["JTFRAME_CHEAT"] = ""
		}
	}
	return macros
}

// Replaces all the macros (marked with a $) in the file
func Replace_Macros(path string, macros map[string]string) string {
	if len(path) == 0 {
		return ""
	}
	file, err := os.Open(path)
	if err != nil {
		log.Fatal("Cannot open " + path)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var builder strings.Builder

	for scanner.Scan() {
		s := scanner.Text()
		for k, v := range macros {
			s = strings.ReplaceAll(s, "$"+k, v)
		}
		builder.WriteString(s)
		builder.WriteString("\n")
	}
	return builder.String()
}
