/var/log/pnda/gobblin/*.log {
    su root root
    daily
    compress
    size 10M
    rotate 5
    copytruncate
}
