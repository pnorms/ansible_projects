- hosts: all
  tasks:
    - name: Make Sure Buffalo Drive Docs Backup Completed, Pat
      command: grep "received" "/Users/thenormans/Buffalo/Pat/Pats_Documents/Sync/`date '+%Y%m%d'`.log"
      register: out_pat
      ignore_errors: yes
      failed_when: '"received" not in out_pat.rc'

    - debug:
        msg: out_pat.stdout

    - name: Make Sure Buffalo Drive Docs Backup Completed, Julie
      command: grep "received" "/Users/thenormans/Buffalo/Julie/Julie_Documents/Sync/`date '+%Y%m%d'`.log"
      register: out_julie
      ignore_errors: yes
      failed_when: '"received" not in out_julie.rc'

    - debug:
        msg: out_julie.stdout

