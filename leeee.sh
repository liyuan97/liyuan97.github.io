#!/usr/bin/expect
set timeout 30
spawn sudo -s
expect "Password:"
send "asdfghjkl;'4\r"
expect "*#"
send "cd /Users/liyuan/hexoblog\r"
expect "*#"
send "hexo s\r"
interact
