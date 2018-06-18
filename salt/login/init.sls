login-copy_event_login:
  file.managed:
    - source: salt://login/files/event-login.sh.tpl
    - name: /usr/sbin/event-login.sh
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

login-sudo_salt_event:
  file.managed:
    - source: salt://login/files/sudoer.tpl
    - name: /etc/sudoers.d/login
    - user: root
    - group: root
    - mode: 440

login-create_login_log:
  file.managed:
    - name: /var/log/pnda/login.log
    - mode: 666
    - makedirs: True

login-create_pam_login_rule:
  file.append:
    - name: /etc/pam.d/login
    - text: |
        auth [auth_err=1 user_unknown=1 default=ignore]	pam_unix.so  	nullok try_first_pass
        auth 	optional 	pam_exec.so    	debug log=/var/log/pnda/login.log /usr/sbin/event-login.sh
