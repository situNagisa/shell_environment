#!/bin/bash
# $TOOLCHAINSPATH/export.sh

function detect_shell(){
	if [ -n "$BASH_VERSION" ]; then
		echo "bash"
	elif [ -n "$ZSH_VERSION" ]; then
		echo "zsh"
	else
		echo ""
	fi
}

function get_env_value(){
	local name="$1"
	local current_shell=$(detect_shell)

	if [ "$current_shell" = "bash" ] || [ -z "$current_shell" ]; then
		echo "${!name}"
	elif [ "$current_shell" = "zsh" ]; then
		echo "${(P)name}"
	fi
}

function env_push_front() {
    local env_var_name="$1"
    local new_value="$2"
    local env_var_old_value=$(get_env_value $env_var_name)

    if [[ -z "$env_var_old_value" ]]; then
        export "$env_var_name=$new_value"
    else
        export "$env_var_name=$new_value:$env_var_old_value"
    fi
}

function export_tool(){
	local directory="$1"

	if [ -d "$directory/bin" ]; then
		env_push_front PATH "$directory/bin"
		if [ -d "$directory/lib" ]; then
			env_push_front LD_LIBRARY_PATH "$directory/lib"
		fi
		if [ -d "$directory/lib64" ]; then
			env_push_front LD_LIBRARY_PATH "$directory/lib64"
		fi
	else
		echo "the \"$directory\" isn't tool"
	fi
}

function export_tools(){
	local root="$1"
	local archs=("aarch64-" "x86_64-" "arm-" "arm64-")

	echo "export tools:"
	for dir in "$root"/*/; do
		local tool=$(realpath --relative-to="$root" "$dir")
		if [ -d "$dir/bin" ]; then
			echo "    $tool"
			export_tool $dir
		fi
	done
}

function export_toolchains(){
	local root="$1"
	local archs=("aarch64-" "x86_64-" "arm-" "arm64-" "i386-" "i486-" "i586-" "i686-")
	
	echo "export toolchains:"
	for dir in "$root"/*/; do
		local tool=$(realpath --relative-to="$root" "$dir")
		for prefix in "${archs[@]}"; do
			if [[ $tool == "$prefix"* ]]; then
				echo "    ${tool}:"
				for cross_dir in "$dir"/*/; do
					local cross_tool=$(realpath --relative-to="$dir" "$cross_dir")
					echo "        $cross_tool"
					export_tool $cross_dir
				done
				break
			fi
		done
	done
}

function dump_machine(){
	local result=$(gcc -dumpmachine)
	if [ $? -eq 0 ]; then
		echo "$result"
	else
		# echo "$(uname -m)-unknown-$(uname -s | tr '[:upper:]' '[:lower:]')"
		echo "error: can't get dump machine, please install gcc"
		exit 1
	fi
}

alias get_local_toolchains="export_toolchains $HOME/target/$(dump_machine)"
alias get_local_tools="export_tools $HOME/target/$(dump_machine)"
