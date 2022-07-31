#!/bin/bash
# sblorgo - simple irc bot
# Copyright (C) 2022 jornmann & contributors
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

tput smcup
clear

version="0.1dev"

server="irc.libera.chat"
if [ "$1" == "" ]; then
	chan="#ff"
else
	chan="$1"
fi
path="$HOME/sblorgo/fifo/${server}/"
prefix=":"

# obviously change these!!!
opers=("jornmann", "nnamnroj", "speedie", "gabubu", "mohamad")
ophost=("user/jornmann", "user/jornmann", "user/speedie", "user/gabubu", "user/damaj301damaj")

printf "\
      '||     '||\`\n\
       ||      ||  \n\
(''''  ||''|,  ||  .|''|, '||''| .|''|, .|''|,\n\
 \`'')  ||  ||  ||  ||  ||  ||    ||  || ||  ||\n\
\`...' .||..|' .||. \`|..|' .||.   \`|..|| \`|..|'\n\
                                     ||\n\
                                  \`..|'\n"
printf "version: $version\n\n\
server: $server\n\
channel: $chan\n\
path: $path\n\
prefix: $prefix\n\
bot ops: $opers\n\
op hosts: $ophost\n\n"

send() {
	printf "$1\n" >> "${path}${chan}/in"
	printf "\e[32m[sent]\e[39m $1\n"
}

nsend() {
	export message="${message}$1"
}

log() {
	i=0
	for o in "${opers[@]}"; do
		o="$(echo $o | sed 's/,//g')"
		echo "/WHO $o" >> "${path}/in"
		sleep 0.5
		h="$(echo ${ophost[$i]} | sed 's/,//g')"
		host="$(tail -n 2 ${path}/out | grep -v 'End of /WHO list.' | awk '{ print $4 }')"
		if [ "$host" = $h ]; then
			printf "/j $(echo $o | sed 's/,//g') sendops: $1\n" >> "${path}/in"
			printf "\e[34m[privsent -> $o]\e[0m $1\n"
		else
			printf "\e[31m[WARNING] $o: $host AND $h DO NOT MATCH!\e[0m\n"
		fi
		i=$((i+1))
		sleep 0.5
	done
}

hostcheck() {
	i=0
	for x in "${opers[@]}"; do
		x=$(echo $x | sed 's/,//g')
		if [ "$1" = "$x" ]; then
			echo "/WHO $1" >> "${path}/in"
			sleep 0.5
			h="$(echo ${ophost[$i]} | sed 's/,//g')"
			host="$(tail -n 2 ${path}/out | grep -v 'End of /WHO list.' | awk '{ print $4 }')"
			if [ "$host" = "$h" ]; then
				return 0
			else
				printf "\e[31m[WARNING] $o: $host AND $h DO NOT MATCH!\e[0m\n"
				return 1
			fi
		else
			[ "$i" = "$((${#opers[@]} - 1))" ] && return 1
		fi
		i=$((i+1))
	done
}

quit() {
	send "Quitting. Reason: $1"
	tput rmcup
	exit 0
}

echo "/j $chan" >> "${path}/in" && printf "\e[34m[sys]\e[39m joined $chan\n"

#trap 'tput rmcup' SIGINT
trap 'quit "Recieved SIGINT."' SIGINT

send "sblorgo initialized!"

tail -n 1 -f "${path}${chan}/out" | while read -r line; do
	cmd=$(printf '%s\n' "$line" | cut -d ' ' -f 3)
	name=$(printf '%s\n' "$line" | cut -d ' ' -f 2 | tr -d '<>')
	if [ "$name" = "jorngirl" ]; then
		if [ "${cmd:0:1}" = "${prefix}" ]; then
			cmd="poop"
		fi
	fi
	if [ "$name" = "sblorgo" ]; then
		if [ "${cmd:0:1}" = "${prefix}" ]; then
			cmd="poop"
		fi
	fi
	if [ "${cmd:0:1}" = "${prefix}" ]; then
		printf "\e[31m[cmd]\e[39m $name used command $cmd\n"
	fi
	case "$cmd" in
		"${prefix}hey")
			send "$name: Hello!"
		;;
		"${prefix}coffee")
			arg=$(printf '%s\n' "$line" | cut -d ' ' -f 4-)
			[ "$arg" = "" ] && send "$name drinks some coffee." || send "$name hands $arg a cup of coffee."
		;;
		"${prefix}tea")
			arg=$(printf '%s\n' "$line" | cut -d ' ' -f 4-)
			[ "$arg" = "" ] && send "$name drinks some tea." || send "$name hands $arg a cup of tea."
		;;
		"${prefix}fortune")
			send "$name: $(fortune -s)"
		;;
		"${prefix}uptime")
			send "$name: $(uptime -p)"
		;;
		"${prefix}about")
			send "$name: sblorgo ${version}, written by jornmann for #ff"
		;;
		"${prefix}rr")
			if (("$RANDOM % 6 + 1" == "1")); then
				send "$name: BANG!! You're dead!"
				echo "/KICK $chan $name" >> "${path}/in"
			else
				send "$name: click..."
			fi
		;;
		"${prefix}coinflip")
			if (("$RANDOM % 2 + 1" == "1")); then
				send "$name: Heads."
			else
				send "$name: Tails."
			fi
		;;
		"${prefix}dice")
			send "$name rolled a $((RANDOM % 6 + 1))."
		;;
		"${prefix}ops")
				send "$name: oplist: ${opers[*]}"
				send "$name: hosts: ${ophost[*]}"
		;;
		"${prefix}help")
			send "$name: commands: coffee, tea, fortune, uptime, about, rr, coinflip, dice, uname, time, penis, hey, ping, test, 8ball, grep, wgrep, sendops, op, deop, voice, devoice, help, quit"
		;;
		"${prefix}penis")
			arg=$(printf '%s\n' "$line" | cut -d ' ' -f 4-)
			length="$(($RANDOM % 16))"
			[ "$arg" = "" ] && export message="${name}'s penis: c" || export message="${name}: ${arg}'s penis: c"
			case "$length" in
				"1") nsend "=" ;;
				"2") nsend "==" ;;
				"3") nsend "===" ;;
				"4") nsend "====" ;;
				"5") nsend "=====" ;;
				"6") nsend "======" ;;
				"7") nsend "=======" ;;
				"8") nsend "========" ;;
				"9") nsend "=========" ;;
				"10") nsend "==========" ;;
				"11") nsend "===========" ;;
				"12") nsend "============" ;;
				"13") nsend "=============" ;;
				"14") nsend "==============" ;;
				"15") nsend "===============" ;;
				"16") nsend "================" ;;
			esac
			[ "$arg" = "CtrlHD" ] && send "CtrlHD's penis: you really think he has one?" || send "${message}3"
		;;
#		"${prefix}search")
#			arg=$(printf '%s\n' "$line" | cut -d ' ' -f 4-)
#			search=$(curl -s 'http://donut.gq:8080/search?q="${arg}"' | grep '"result-1"' | sed 's/.*aria-labelledby="result-1">// ; s/<span class="highlight">// ; s/<\/span>// ; s/<\/a>.*//')
#			send "$name: $search"
#		;;
		"${prefix}uname")
			send "$name: $(uname -a)"
		;;
		"${prefix}time")
			send "$name: $(date +%s)"
		;;
		"${prefix}ping")
			send "$name: Pong!"
		;;
		"${prefix}wgrep")
			arg=$(printf '%s\n' "$line" | cut -d ' ' -f 4-)
			results=$(grep "$arg" "${path}${chan}/out" | wc -l)
			[ "$arg" = "" ] && send "$name: $results messages in backlog." || send "$name: Found '$arg' in $results message(s)."
		;;
		"${prefix}test")
			arg=$(printf '%s\n' "$line" | cut -d ' ' -f 4-)
			if [ ! "$arg" = "" ]; then
				if (("$RANDOM % 2 + 1" == "1")); then
					send "$name: Checking if $arg... [   OK   ]"
				else
					send "$name: Checking if $arg... [ FAILED ]"
				fi
			else
				send "$name: You need an argument for this!"
			fi
		;;
		"${prefix}8ball")
			case "$(($RANDOM % 19))" in
				"0") send "$name: It is certain." ;;
				"1") send "$name: It is decidedly so." ;;
				"2") send "$name: Without a doubt." ;;
				"3") send "$name: Yes definitely." ;;
				"4") send "$name: You may rely on it." ;;
				"5") send "$name: As I see it, yes." ;;
				"6") send "$name: Most likely." ;;
				"7") send "$name: Outlook good." ;;
				"8") send "$name: Yes." ;;
				"9") send "$name: Signs point to yes." ;;
				"10") send "$name: Reply hazy, try again." ;;
				"11") send "$name: Ask again later." ;;
				"12") send "$name: Better not tell you now." ;;
				"13") send "$name: Cannot predict now." ;;
				"14") send "$name: Concentrate and try again." ;;
				"15") send "$name: Don't count on it." ;;
				"16") send "$name: My reply is no." ;;
				"17") send "$name: My sources say no." ;;
				"18") send "$name: Outlook not so good." ;;
				"19") send "$name: Very doubtful." ;;
			esac
		;;
		"${prefix}grep")
			arg=$(printf '%s\n' "$line" | cut -d ' ' -f 4-)
			results=$(cut -b 12- "${path}${chan}/out" | grep -i "${arg}" | tail -n 6 | sed '$d')
			[ "$results" = "" ] \
				&& send "$name: no results for '$arg'" \
				|| send "$name: $results"
		;;
		"${prefix}sendops")
			arg=$(printf '%s\n' "$line" | cut -d ' ' -f 4-)
			log "$arg"
			send "$name: Sent."
		;;
		"${prefix}op")
			hostcheck "$name"
			if [ $? -eq 0 ]; then
				echo "/j chanserv op ${chan} $name" >> "${path}/in"
			else
				send "$name is not in the sudoers file. This incident will be reported."
			fi
		;;
		"${prefix}deop")
			hostcheck "$name"
			if [ $? -eq 0 ]; then
				echo "/j chanserv deop ${chan} $name" >> "${path}/in"
			else
				send "$name is not in the sudoers file. This incident will be reported."
			fi
		;;
		"${prefix}voice")
			hostcheck "$name"
			if [ $? -eq 0 ]; then
				echo "/j chanserv voice ${chan} $name" >> "${path}/in"
			else
				send "$name is not in the sudoers file. This incident will be reported."
			fi
		;;
		"${prefix}devoice")
			hostcheck "$name"
			if [ $? -eq 0 ]; then
				echo "/j chanserv devoice ${chan} $name" >> "${path}/in"
			else
				send "$name is not in the sudoers file. This incident will be reported."
			fi
		;;
		"${prefix}quit")
			hostcheck "$name"
			if [ $? -eq 0 ]; then
				send "NO! DON'T KILL ME!"
				send "/l Recieved 'quit' command from $name."
				exit
			else
				send "$name is not in the sudoers file. This incident will be reported."
			fi
		;;
	esac
done
