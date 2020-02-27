#!/usr/local/bin/expect 
set timeout -1
spawn sudo -s
expect {
        "(yes/no)" { send "yes\r"; exp_continue }
        "Password:" { send "asdfghjkl;'4\r" }
        "#" {send "sudo -s&&hexo clean&&hexo g&&hexo d\r"}
}
expect "#"
send "hexo clean&&hexo g&&hexo d\r"
interact