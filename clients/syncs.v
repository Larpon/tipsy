import os
import term
import flag
import time

fn main() {

    mut warning_display := false

    mut fp := flag.new_flag_parser(os.args)
    fp.application('syncs')
    fp.version('v0.1.0')
    fp.description('Syncs a simple tipsy context console client')

    fp.skip_executable()

    pid := fp.int('pid', 0, 0, 'Read context from <pid> tipsy process')

    tips_dir := fp.string('tips', 0, '', 'Path to tips')
    if !os.is_dir(tips_dir) {
        warning_display = true
        eprintln('Tips directory "$tips_dir" doesn\'t exist')
    }

    //additional_args :=
    fp.finalize() or {
        eprintln(err)
        println(fp.usage())
        return
    }

    tipsy_work := [os.temp_dir(), '.tipsy'].join(os.path_separator)

    if warning_display {
        time.sleep(2000 * time.millisecond)
    }

    mut tpid := 0
    mut app := ''
    for {
        running := os.ls(tipsy_work) or { panic(err) }

        if running.len <= 0 {
            time.sleep(2000 * time.millisecond)
            continue
        }

        if tpid == 0 && running[0].int() != tpid {
            if pid > 0 {
                for spid in running {
                    if spid.int() == pid {
                        tpid = pid
                    }
                }
            }
            if tpid == 0 { tpid = running[0].int() }
            println('Using tipsy instance '+tpid.str())
        }

        context_dir := [tipsy_work,tpid.str(),'context'].join(os.path_separator)
        tapp := os.read_file([context_dir,'app'].join(os.path_separator)) or { continue }
        if tapp != app {
            app = tapp

            term.clear()

            app_file := [tips_dir,'$app'].join(os.path_separator)
            if os.exists(app_file) {
                tip := os.read_file(app_file) or { continue }
                println(tip)
            } else {
                println('No tip for '+app)
            }
        }

        time.sleep(1000 * time.millisecond)
    }

}
