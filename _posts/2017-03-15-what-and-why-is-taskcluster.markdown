---
layout: post
title: What and Why is Taskcluster
---

Taskcluster is the task execution framework that supports Mozilla's continuous integration and release processes. Like any system of its size, Taskcluster can be different things to different people. Probably the most common context that it is used in is in its life as a CI system for Firefox at Mozilla. From that perspective, it is an extremely customizable framework for building your own CI system, much in the tradition of [Buildbot](http://buildbot.net/). Some helpful people have used the framework to build a [Github-specific integration](https://tools.taskcluster.net/quickstart/) much like [Travis](https://travis-ci.org/) or [CircleCI](https://circleci.com/), so in a sense Taskcluster is like those as well. At the end of the day, the part of Taskcluster that ties all of that together is the platform it provides for running tasks in a cluster of machines -- hence, the hard-to-type and hard-to-say name.

Taskcluster does a lot of hard work. As of the last 30 days leading up to the date of this post, we've done:

```
Total Tasks (30 days)
5,229,327

Total Task Time (30 days)
225.57 years

Unique machines (30 days)
695,734

Average task duration
40.7 minutes
```

That covered 6113 `try`, 1002 `inbound`, and 134 `central` pushes, responsible for 2101346, 632790, and 252421 tasks respectively. The task time per machine averages out to about 2 hours per machine. We try to keep machines as fresh as possible (no machine lives more than a day), but also try to push machines up as close to the end of billing periods as possible.

We'll cover a few aspects of Taskcluster here. First is our [guiding design principles](https://docs.taskcluster.net/manual/devel/principles#guiding-design-principles-for-taskcluster) and how they help us build a robust, easy-to-use system. In the next post we'll follow the life of a task as it bumps around Taskcluster. From there we'll see how we use it at Mozilla (in combination with some of our other tools) to solve some classic CI problems. Finally we'll cover some future work.

### Guiding Principles

About a year ago the team met up for our confusingly named [2016 Worker Work Week](http://www.chesnok.com/daily/2016/03/11/workweek-tc-worker-workweek-recap/). One of the products of the week was a list of principles that we had been unofficially following up to that point and that we have been using to guide our decision making since then.

#### Self-service

This goes a step further than just making sure CI configuration is inside user's repositories. In addition to that we provide a flexible permissions system based on something we call [scopes](https://docs.taskcluster.net/manual/integrations/apis/scopes). Each action in Taskcluster can be guarded by a set of scopes (which are just strings) that a client must have. Scopes can either be an exact match, or be matched by a splat suffix.

```
Action Requires: notify.irc.bstack.on_failure
Client Has: notify.irc.*
Success: true
```

Importantly, clients can assign scopes to other clients if they already posses that scope. So this allows us to endow certain users with the ability to give scopes to other users. Entire ecosystems of scopes can exist within Taskcluster without needing to involve the Taskcluster team itself.

There are a few other ways that this rule manifests, but we'll cut short here.

#### Robustness

This is not a particularly surprising rule to live by for a CI system. However, anybody who uses a CI system on a day-to-day basis probably knows this is one of the most difficult goals to achieve. I can say as a relatively new member of this team and someone who's worked on a number of other build systems that compared to how rapidly we add features to Taskcluster and how heavily used it is, it breaks quite infrequently. I think this is due to a few of the principles we have in particular:

- No state in our services … ever!
- No running our own datastores … ever!
- Anything that can return a potentially unbounded list must be paginated.

The first two are surprisingly hard to keep and my dinosaur brain constantly wants to break them for one reason or another. Keeping discipline within the team on this point has so far always ended up producing surprising/different ways of solving problems in a manner that still allows us to rely on external providers for the Hard Parts™.

Another aspect of robustness is supporting large, complex to build projects like Firefox. This guides many of the decisions we make and is something that is different between Taskcluster and something like Travis.

#### Enable rapid change

This is very near-and-dear to our hearts on Taskcluster. It is probably the primary reason something like Taskcluster exists in the first place. Buildbot is an awesome project and when used correctly, can do amazingly complex things. 
A recurring issue with many installs of Buildbot is that configuration becomes ossified over time. This is due to configuration taking place separately from a project's source code and the configuration being complex enough that generally people become Buildbot specialists.

Taskcluster was designed from the ground up to not have this issue. A single task can easily be designated in a small yaml file and more complex graphs of tasks with dependencies can be built up without too much effort, but in either case all configuration will live in your tree, not in Taskcluster itself.

Another side of this is that Taskcluster itself is easy to change and add features to. We have a few services that are completely maintained by contributors. We also have a number of services that hook into events published by Taskcluster and are run entirely by other teams withing Mozilla.

#### Community friendliness

As mentioned before we have parts of Taskcluster that are entirely contributor run and are looking to expand that as time goes on. Part of this is the Mozilla-y-ness of the project. Pretty much everything happens in public. Anybody can come to our weekly meetings and anybody can sit in our irc channel. We are starting weekly events that are purely for community interaction that are mostly for just hanging out and chatting about semi-related things. [The meetings](https://wiki.mozilla.org/TaskCluster/Reading_By_Moonlight) change time every week to make it easy for people all over the world to show up. You should show up sometime and say hi!

### The Life of a Task

We've talked about why Taskcluster is the way it is. Now we'll talk about how it works. We'll talk about what a task is and what happens to it. Let's meet our task.

```json
{
  "taskGroupId": "BjadQTTpRiu5RZGBKIIw-Q",
  "dependencies": ["RLBIMCE-SZ-sdrmM5QInuA"],
  "requires": "all-completed",
  "provisionerId": "aws-provisioner-v1",
  "workerType": "taskcluster-generic",
  "schedulerId": "-",
  "routes": [
    "index.project.taskcluster.example-task",
    "notify.email.bstack@mozilla.com.on-failed",
    "notify.email.bstack@mozilla.com.on-exception"
  ],
  "priority": "normal",
  "retries": 5,
  "created": "2017-03-15T16:31:27.771Z",
  "deadline": "2017-03-16T16:31:27.771Z",
  "expires": "2017-06-15T16:31:27.771Z",
  "scopes": [
    "auth:aws-s3:read-write:taskcluster-backups/"
  ],
  "payload": {
    "image": "node:7",
    "command": [
      "/bin/bash",
      "-c",
      "git clone https://github.com/taskcluster/taskcluster-backup.git && cd taskcluster-backup && yarn global add node-gyp && yarn install && npm run compile && node ./lib/main.js backup"
    ],
    "maxRunTime": 86400,
    "env": {
      "FOO": "bar"
    }
  },
  "metadata": {
    "name": "A task in taskcluster",
    "description": "This does a thing in taskcluster",
    "owner": "bstack@mozilla.com",
    "source": "https://something-related-to-this.com/whatever"
  }
}
```

Hello task, nice to meet you. This format is defined by a JSON schema and has [autogenerated docs](https://docs.taskcluster.net/reference/platform/queue/docs/task-schema) (as do all of our api endpoints).

#### The Queue Service

You take that task definition and send it to the taskcluster queue. This is the piece of the system that manages tasks and task dependencies. We can specify in the requires field whether or not the task should block on the prior tasks merely finishing, or whether they need to finish successfully. In our task, `RLBIMCE-SZ-sdrmM5QInuA` must finish with a successful status before our task will begin. Let's talk about those funny strings in `taskGroupId` and `dependencies` are and what "successful" means a bit more.

The task IDs are generated by clients rather than the server. Our client libraries have some helper functions to generate one when you create a task. They are 22 character URL-safe base64 v4 UUIDs (see [RFC 4648 sec. 5](http://tools.ietf.org/html/rfc4648#section-5)). Basically, these are strings that won't collide and you can safely generate as many of them as you want and use them to identify tasks and task groups within Taskcluster. Referring back to the design principles from the first post, we make the client generate these to allow for idempotent retries when creating tasks.

Task groups are for the most part a convenient way of relating tasks that are part of a larger whole together for easy viewing, they don't do much more than that. Dependencies can exist between task groups.

Tasks can resolve in a few different ways that have different semantic meanings. The possible task states are `unscheduled pending running completed failed exception`. Taskcluster will label tasks as `exception` if something within taskcluster caused a task to fail to complete and it will automatically retry up to the number of times you specify in `retries`. Failures that you introduce (say something like a test in your CI suite failing) will cause the task to be `failed` and these are not retried. If you want to have retries around a flaky test, you build that into your test executing inside the task yourself. We've had a lot of internal discussions about that point in particular, and perhaps that will make a good post someday. The guiding principles are useful for thinking about why not to do this though.

#### The Auth Service

On to some other fields in our friendly task. What are scopes and how do you use them? Every service in Taskcluster can specify that an endpoint needs a client to have certain scopes before it will run. The service that maintains clients and their relation to scopes is called the auth service. The most important [endpoint](https://docs.taskcluster.net/reference/platform/auth/references/api#authenticateHawk) that service provides is a way to validate [Hawk](https://github.com/hueniverse/hawk/) credentials. In this manner, we keep all credentials only known by the auth service itself and the client that has them. We can happily add new services to the Taskcluster ecosystem and trust them not to leak credentials. This aligns with our desires to be community friendly from the guiding principles.

As much as possible, we try to have services have no credentials of their own. Each time a service has credentials and it tries to reduce its power to use them on behalf of a client, we have an opportunity for a [confused deputy](https://en.wikipedia.org/wiki/Confused_deputy_problem). Avoiding those sorts of situations are very important to us.

#### Routing Events

One of the more confusing fields in the task definition is the `routes` field.

```json
{
  "routes": [
    "index.project.taskcluster.example-task",
    "notify.email.bstack@mozilla.com.on-failed",
    "notify.email.bstack@mozilla.com.on-exception"
  ]
}
```

All Taskcluster services can emit events into [RabbitMQ](http://www.rabbitmq.com/) based on certain events. Unsurprisingly, all services can also listen for events. Adding routes to the routes field of a task will cause the queue to emit events on task completion. Our example task here emits 3 routes. The first one is listened for by the index service, which stores the taskId as the value to a key that is whatever the rest of that route is. So in this case, you can ask the index service for `project.taskcluster.example-task` and it will tell you whatever the most recent task that was labeled that way was. We use this for finding artifacts of the latest builds of a branch for instance. Which routes you are allowed to write to are controlled by scopes to prevent unauthorized overwrites.

The `notify.*` fields route to the notifications service which can send emails or irc messages. You can ask it to alert you on failures, exceptions, success, or all of the above.

These services also expose an API if you wish to add custom indexing our notifications. For instance, we have users that generate daily reports and send them to themselves with the notifications service.

That brings up one other note, Taskcluster provides a hooks service that allows you to have cron-style jobs that execute based on time. This takes care of common cases like a nightly performance report or daily backups.

#### Workers and the Provisioner

We keep talking about tasks running, but where do they run and how do they do it? Tasks run on workers. Workers can be many things, but they all share a couple things:

- They ask the queue for work
- They have a way of running that work
- They report back to the queue the status of the work

Generally what this means at this point is an instance of our [Docker worker](https://github.com/taskcluster/docker-worker) running on a Linux machine in AWS. The `payload` section of our task is what the worker is interested in. Once the queue gives a task to work on, the worker looks there to see what to do.

```json
{
  "payload": {
    "image": "node:7",
    "command": [
      "/bin/bash",
      "-c",
      "git clone https://github.com/taskcluster/taskcluster-backup.git && cd taskcluster-backup && yarn global add node-gyp && yarn install && npm run compile && node ./lib/main.js backup"
    ],
    "maxRunTime": 86400,
    "env": {
      "FOO": "bar"
    }
  }
}
```

The task we've been looking at is designed to run on docker-worker. It specifies that it wants a container based on the `node:7` image to run the commands listed in the `command` field. We want the task to be killed after 24 hours, and we want the env to have a variable called `FOO` with the value of `bar` in it. It is pretty self-explanatory. How did we know we would be running this task on a docker-worker though?

```json
{
  "provisionerId": "aws-provisioner-v1",
  "workerType": "taskcluster-generic"
}
```

This tells the queue which sorts of workers should be allowed to request the task. A provisioner is a service that manages a set of machines running workers and the `workerType` is a definition within that provisioner of a type of worker. That includes things like which OS version, which cloud provider, which version of Docker, and how much space should be available on the machine in addition to which worker client is running there.

We allow for many different worker types. Some of the most well supported provide some great features. Docker worker allows for an interactive session to be started with access to both the command line inside the running task and the screen output. This makes quick work of oftentimes hard-to-debug test issues that only happen in CI but not locally. Again, access to all of this is guarded by scopes.

At this time there's basically one provisioner and it runs an autoscaling group of nodes in AWS that grow and shrink as demand changes in the queue. We are doing a lot of work in this part of our stack to provide more platforms to developers.

### Use Cases

Taskcluster does not make a full CI/CD system on its own. Mozilla has quite a few other open-source tools that make up our full set of systems. Some of these, like the service that [integrates us with Github](https://github.com/integration/taskcluster) are managed by the Taskcluster team, while others are run by other teams within Mozilla.

For the building and testing of Gecko itself, a lot of tools work together to make the system run smoothly. Two of the most important tools here are [Treeherder](https://treeherder.mozilla.org/) and [Orange Factor](https://brasstacks.mozilla.com/orangefactor/). These are focused on the tests themselves, which Taskcluster does not concern itself with. They are quite powerful tools, used by developers and the tree caretakers (called sheriffs) alike. Orange Factor is one of the tools we use for tracking flaky tests. The Taskcluster team is occasionally responsible for things that show up in Orange Factor, so we keep a close eye on the dashboard as well.

From there, we need to actually publish new version of Firefox to the world. [Balrog](https://github.com/mozilla/balrog), [funsize](https://github.com/mozilla-releng/funsize), and [beetmover](https://github.com/mozilla-releng/beetmoverscript) interact with Taskcluster to make updates available for Firefox users when we push new code.

### Future Work

Conveniently, we're beginning our quarterly planning now, so it will be easy to see across the entire team what we're going to be focusing on in the next few months.

- Get 100% of Firefox build into Taskcluster
- A [QEMU](http://www.qemu-project.org/) based engine in our worker
- Syncing of Github and Taskcluster permissions
- Real-Time Queue + Worker inspection to track the full lifetime of a task
- Improved security audit tooling and further security hardening
- Redeployability and general cluster management improvements

In general our team is working mostly on finishing the migration from Buildbot to Taskcluster at this time, but as that work wraps up, we'll move onto further integration/core improvements and making operations/redeployability easier.

If you're interested in helping out, here are some good resources:

- [Docs Site](https://docs.taskcluster.net/)
- [Tools Site](https://tools.taskcluster.net/)
- [Wiki](https://wiki.mozilla.org/TaskCluster)
- [Github](https://github.com/taskcluster/)
- [Bugs Ahoy!](https://www.joshmatthews.net/bugsahoy/?taskcluster=1)
- [Good First Bugs](https://bugzilla.mozilla.org/buglist.cgi?cmdtype=dorem&remaction=run&namedcmd=Taskcluster%20good%20first%20bugs&sharer_id=464696&list_id=13490731)
- [Slightly Larger Projects](https://wiki.mozilla.org/TaskCluster/Round_Tuit_Box)
- #taskcluster on [Mozilla IRC](https://wiki.mozilla.org/IRC)
- [People of Taskcluster](https://docs.taskcluster.net/people)
