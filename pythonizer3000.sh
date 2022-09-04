#!/usr/bin/env bash

ScriptName=$2
OutScriptName=$3
#ScriptName="kube_tunnel.sh"
#OutScriptName="kube_tunnel.py"
readonly PyScriptTemplate=''
readonly PyVarTemplate='bashSeq = ( replace_label )'
PyVar=""
PyVarPayload=""

#========================FUNC_SECTION========================
function func_script_processors() {
    local sLine=""
    local varArgs=""

    while read sLine
    do
        if [[ ! -z "$varArgs" ]]
        then {
            varArgs=${varArgs}",""'${sLine}'"
        }
        else {
            varArgs="'${sLine}'"
        }
        fi
        
    done < "${ScriptName}"
    echo "${varArgs}"
    PyVarPayload="${varArgs}"
}
func_py_script_creator () {
    local PyVar="$PyVarTemplate"
    PyVar=${PyVar/replace_label/$PyVarPayload}
    cat /dev/null > "${OutScriptName}"
    echo "import subprocess" | tee -a "${OutScriptName}" 
    echo "import os" | tee -a "${OutScriptName}"
    echo 'subprocess.call("cat /dev/null > temp.sh", shell=True)' | tee -a "${OutScriptName}"
    echo "${PyVar}" | tee -a "${OutScriptName}"
    echo "for command in bashSeq:" | tee -a "${OutScriptName}"
    echo '  with open("temp.sh", "a") as o:' | tee -a "${OutScriptName}"
    echo '    o.write(command + "\n")' | tee -a "${OutScriptName}"
    echo 'subprocess.call("temp.sh", shell=True)' | tee -a "${OutScriptName}"
}

#=============================================================

func_script_processors
func_py_script_creator