#!/bin/bash
# Cron job setup and verification script

echo "Setting up cron job..."

# Add cron job to run every 5 minutes
(crontab -l 2>/dev/null; echo "*/5 * * * * echo \"Cron Job Running at $(date)\" >> ~/cron_log.txt") | crontab -

echo "Cron job added successfully!"
echo ""
echo "Current crontab entries:"
crontab -l
echo ""
echo "Cron job will run every 5 minutes and log to ~/cron_log.txt"
echo "To remove the job later, run: crontab -r"
