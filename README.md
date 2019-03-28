## New Relic Kubernetes Logging

Welcome to the New Relic Fluent Bit Output Plugin for Kubernetes! There are only a few quick steps to getting this working in your cluster.

1. Pull down this repo
2. On line 27 of `new-relic-fluent-plugin.yml`, input your own New Relic Insights Insert key. Instructions on how to get your New Relic Insights Insert key can be found [here](https://docs.newrelic.com/docs/insights/insights-data-sources/custom-data/send-custom-events-event-api).
3. Log into quay.io on your cluster. We think that this way is easiest:
  ```
    kubectl create secret docker-registry regcred --docker-server=quay.io --docker-username=<your-quay.io-username> --docker-password=<your-quay.io-pword> --docker-email=<your-quay.io-email>
  ```

To learn about more ways to log in, check out [this documentation](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/). Make sure to name your secret `regcred` though.

4. Once that's all ready, run `kubectl apply -f fluent-conf.yml -f new-relic-fluent-plugin.yml` on your cluster. Then check Insights for your logs by running `SELECT * FROM log`!

We default to tailing `/var/log/containers/*.log`. If you want to change what's tailed, just update the path on line 28 of `fluent-conf.yml`.

Latest image version: 0.0.19

We currently support parsing json and docker logs. If you want more parsing, feel free to add more parsers in `fluent-conf.yml`.

Here are some parsers for your parsing pleasure. 

```
[PARSER]
    Name   apache
    Format regex
    Regex  ^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^\"]*?)(?: +\S*)?)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$
    Time_Key time
    Time_Format %d/%b/%Y:%H:%M:%S %z

[PARSER]
    Name   apache2
    Format regex
    Regex  ^(?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^ ]*) +\S*)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$
    Time_Key time
    Time_Format %d/%b/%Y:%H:%M:%S %z

[PARSER]
    Name   apache_error
    Format regex
    Regex  ^\[[^ ]* (?<time>[^\]]*)\] \[(?<level>[^\]]*)\](?: \[pid (?<pid>[^\]]*)\])?( \[client (?<client>[^\]]*)\])? (?<message>.*)$

[PARSER]
    Name   nginx
    Format regex
    Regex ^(?<remote>[^ ]*) (?<host>[^ ]*) (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^\"]*?)(?: +\S*)?)?" (?<code>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$
    Time_Key time
    Time_Format %d/%b/%Y:%H:%M:%S %z
    ```
