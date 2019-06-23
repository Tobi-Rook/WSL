function s
	# Default case
	if test (count $argv) -eq 0
		cat /etc/*-release
	else
		set -g s 1
		while ! test -z $argv[$s]
			switch $argv[$s]
			case help
				cat ~/.config/fish/functions/help/s | less
			case '*'

				# Start statement (--> Windows Command Prompt)
				if echo $argv[$s] | grep -i '^start' | grep -ivq '^[a-z]:'
					echo "$argv[$s]" | cmd.exe > /dev/null 2> /dev/null

				# Windows file paths / WSL / Linux distributions
				else 

					# Insertion of placeholders for a few incompatible chars
					set -l file_Path (readlink -f $argv[$s] |
					tr Ä '{A1' | tr ä '{A2' | tr Å '{A3' | tr å '{A4' |
					tr É '{E1' | tr é '{E2' |
					tr Ñ '{N1' | tr ñ '{N2' |
					tr Ö '{O1' | tr ö '{O2' | tr Ø '{O3' | tr ø '{O4' |
					tr ß '{S1' |
					tr Ü '{U1' | tr ü '{U2')

					# Passed Windows file path
					if echo $argv[$s] | grep -iq '^[a-z]:'
						set -l file_Path_Win (echo $file_Path | sed "s|$PWD||g" | cut -b 2-)

						# .pdf file extension
						if echo $file_Path_Win | grep -iq '.pdf$'
							echo "\"$DISK:\Users\%USERNAME%\\$WSL_DIR\wslstart.bat\" pdf \"$file_Path_Win\" \"$DISK:\\$BROWSER\"" | cmd.exe > /dev/null 2> /dev/null &

						# .exe / .bat / .lnk extension
						else if echo $file_Path_Win | grep -iqE '.exe$|.bat$|.lnk$'
							echo "\"$DISK:\Users\%USERNAME%\\$WSL_DIR\wslstart.bat\" exe \"$file_Path_Win\"" | cmd.exe > /dev/null 2> /dev/null &

						# Other file extensions
						else
							echo "\"$DISK:\Users\%USERNAME%\\$WSL_DIR\wslstart.bat\" start \"$file_Path_Win\"" | cmd.exe > /dev/null 2> /dev/null &
						end

					# Execution within the WSL
					else if echo $file_Path | grep -iq '/mnt/[a-z]/'

						# Linux file path conversion
						set -l file_Path_Win (echo $file_Path | sed 's/\//\\\\/g' | cut -b 6- | sed 's/^\(.\{1\}\)/\1:/')

						# .pdf file extension
						if echo $file_Path_Win | grep -iq '.pdf$'
							echo "\"$DISK:\Users\%USERNAME%\\$WSL_DIR\wslstart.bat\" pdf \"$file_Path_Win\" \"$DISK:\\$BROWSER\"" | cmd.exe > /dev/null 2> /dev/null &

							# Temporarily required if the function call results in opening a canary / dev / beta build of a Chromium-based browser
							set -U pwd $PWD
							fish -c 'wsl r "$pwd/debug.log" $BROWSER_E' > /dev/null &

						# .exe / .bat / .lnk extension or whitespaces in the file's absolute path
						else if echo $file_Path_Win | grep -iqE '.exe$|.bat$|.lnk$'
							echo "\"$DISK:\Users\%USERNAME%\\$WSL_DIR\wslstart.bat\" exe \"$file_Path_Win\"" | cmd.exe > /dev/null 2> /dev/null &

						# Other file extensions
						else
							echo "\"$DISK:\Users\%USERNAME%\\$WSL_DIR\wslstart.bat\" start \"$file_Path_Win\"" | cmd.exe > /dev/null 2> /dev/null &
						end

					# Execution within any Linux distribution
					else
						set -l WSL_DISTRO_DIR (echo WSL_(echo $WSL_DISTRO_NAME)_DIR)

						# .pdf file extension
						if echo $argv[$s] | grep -iq '.pdf'
							set -l file_Name (basename $file_Path)
							cp $argv[$s] /mnt/$DISK/users/$USER/
							echo "\"$DISK:\Users\%USERNAME%\\$WSL_DIR\wslstart.bat\" pdf \"$DISK:\Users\%USERNAME%\\$file_Name\" \"$DISK:\\$BROWSER\"" | cmd.exe > /dev/null 2> /dev/null &
							fish -c 'wsl r '/mnt/$DISK/users/$USER/$argv[$s]' $BROWSER_E' > /dev/null 2> /dev/null &

						# Check if the current distribution is registered as a valid distribution in the WSL (--> $WSL_X_DIR)
						else if test -n $$WSL_DISTRO_DIR

							# .exe / .bat / .lnk file extension
							if echo $argv[$s] | grep -iqE '.exe$|.bat$|.lnk$'
								echo "\"$DISK:\Users\%USERNAME%\\$WSL_DIR\wslstart.bat\" exe \"\\\\wsl\$\\$WSL_DISTRO_NAME\\$file_Path\"" | cmd.exe > /dev/null 2> /dev/null &

							# No file extension
							else if echo $argv[$s] | grep -iqv '\.'
								echo "\"$DISK:\Users\%USERNAME%\\$WSL_DIR\wslstart.bat\" no \"\\\\wsl\$\\$WSL_DISTRO_NAME\\$file_Path\"" | cmd.exe > /dev/null 2> /dev/null &

							# Other file extensions
							else
								echo "\"$DISK:\Users\%USERNAME%\\$WSL_DIR\wslstart.bat\" cmd \"\\\\wsl\$\\$WSL_DISTRO_NAME\\$file_Path\"" | cmd.exe > /dev/null 2> /dev/null & 
							end

						# Distribution is not compatible / Distribution needs to be registered (--> $WSL_X_DIR)
						else
							echo "Operation not supported."
						end
					end
				end
			end
			set -g s (math $s+1)
		end
	end
end

