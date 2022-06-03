#!/bin/bash
# sblorgo - simple irc bot
# Copyright (C) 2022 jornmann & contributors
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

version="0.1dev"

server="irc.libera.chat"
chan="#ff"
path="$HOME/sblorgo/fifo/${server}/"
prefix=":"

printf "\n\
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
prefix: $prefix\n\n"

send() {
	printf "$1\n" >> "${path}${chan}/in"
	printf "\e[32m[sent]\e[39m $1\n"
}

nsend() {
	export message="${message}$1"
}

echo "/j $chan" >> "${path}/in" && printf "\e[34m[sys]\e[39m joined $chan\n"

tail -n 1 -f "${path}${chan}/out" | while read -r line; do
	cmd=$(printf '%s\n' "$line" | cut -d ' ' -f 3)
	name=$(printf '%s\n' "$line" | cut -d ' ' -f 2 | tr -d '<>')
	if [ "$name" = "jorngirl" ]; then
		if [ "${cmd:0:1}" = "${prefix}" ]; then
			send "Fuck off."
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
			send "$name: sblorgo ${version}\nwritten by jornmann for #ff\n"
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
		"${prefix}help")
			send "$name: commands: coffee, tea, fortune, uptime, about, rr, coinflip, dice, uname, time, penis, hey, ping, test, 8ball, grep, help"
		;;
		"${prefix}penis")
			arg=$(printf '%s\n' "$line" | cut -d ' ' -f 4-)
			length="$(($RANDOM % 16))"
			[ "$arg" = "" ] && export message="${name}'s penis: c" || export message="${name}: ${arg}'s penis: c"
			# I know this is a shitty way to do it, but it works.
			# TODO: Make this not terrible!
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
	esac
done
