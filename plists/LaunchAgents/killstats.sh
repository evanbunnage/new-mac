#!/bin/zsh

IS_ON_BATTERY=$(pmset -g batt | grep 'Battery Power')

if [[ $IS_ON_BATTERY ]]; then
  STATS_PID=$(pgrep -f 'Stats.app')
  # If Stats is running, kill it
  if [[ ! -z $STATS_PID ]]; then
    kill $STATS_PID
  fi
fi
