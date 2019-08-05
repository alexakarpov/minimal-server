[![CircleCI](https://circleci.com/gh/alexakarpov/minimal-server.svg?style=svg)](https://circleci.com/gh/alexakarpov/minimal-server)

A task from an interviewing process about an year ago. My first Elixir code; after, I've added Kafka log, REST API and supervision.

# MinimalServer

A CNC machine produces a part every 30 seconds. (You can see an example here to get an idea of what the process looks like: https://www.youtube.com/watch?v=RNPojGFg9-8) After the machine is done producing a part, an operator will come into the machine, remove the part, and load the machine with new raw materials.
Your goal is to produce an application that receive events from machines as they complete parts (sent via a message to your actor/process as shown above). Your application will monitor their activity and log the activity to a journal. You will write events to a journal of your choosing (a file, a redis sorted set ranked by time, or a kafka topic.)

Once a part is complete, your process will receive a message from the machine as shown:
```
{“machine_id”: “1”, “type”: “CycleComplete”, “timestamp”: “2017-12-09T00:38:31Z”}
```
Assume the timestamp is when the event occurred, and it may be received by your code up to two seconds after it occurs.
You want to build an application that will receive these `cycle` events and will store them in the journal with both the cycle time and a recorded timestamp like so:
```
{“machine_id”: “1”, “type”: “MachineCycled”, “event_time”: “2017-12-09T00:38:31Z”, “recorded_at”: “2017-12-09T00:39:22Z”}
```
The machine takes 30 seconds to process a part. After the machine is complete, it takes an operator 10 seconds to load new materials before the machine can start working again . So 40 seconds total are allotted for each cycle. If 45 seconds pass between receiving cycles, you should also write an event at the 45 second mark from the time that the cycle finished (eg 45 seconds from the timestamp you receive for the cycle) to indicate that productivity has been negatively impacted:
```
{“machine_id”: “1”, “type”: “NonProductionLimitReached”, “recorded_at”: “2017-12-09T01:23:31Z”}
```
If 60 seconds pass without receiving any data, something may be wrong, so you should write an event:
```
{“machine_id”: “1”, “type”: “AlarmOpened”, “recorded_at”: “2017-12-09T01:38:31Z”}
```
If the application has produced an alarm, when it receives a cycle, you should write an AlarmClosed message before recording the cycle.
```
{“machine_id”: “1”, “type”: “AlarmClosed”, “recorded_at”: “2017-12-09T02:38:31Z”}
```

# How to build/run this

**iex -S mix**

now, make POST to:
http://localhost:4000/events

e.g.
```
curl -d '{"machine_id":"M1", "time":4321}' -H "Content-Type: application/json" -X POST http://localhost:4000/events
```
(timestamp is not really important though)

see the logs written to journal.log, and run your own Kafka consumer on 'events' topic using the url from the config.exs, e.g.:
```
./bin/kafka-console-consumer.sh --bootstrap-server kafka.alexakarpov.xyz:9092 --topic events --from-beginning
```
