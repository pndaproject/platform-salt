#!/bin/bash
/bin/echo ruok | /bin/{{netcat}} localhost 2181 | /bin/grep 'imok'