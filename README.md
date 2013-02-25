What?
=====

A quick way to get a mcollective network built for testing or evaluating MCollective.

The network will consist of a single node that acts as a middleware server using
Redis and a configurable amount of nodes under management.  On a 32GB machine I
have no problem running 26 machines using this repository.

This consists of a Vagrant file and a few **very** simple Puppet Modules that does the
simplest possible thing to get a MCollective setup going.

This setup uses Redis for the middleware, discovery and registration thus providing
a very light weight and fast setup.

This will setup the latest development MCollective along with the following plugins:

   * [Package Agent](https://github.com/puppetlabs/mcollective-package-agent)
   * [Service Agent](https://github.com/puppetlabs/mcollective-service-agent)
   * [Puppet Agent](https://github.com/puppetlabs/mcollective-puppet-agent)
   * [File Manager Agent](https://github.com/puppetlabs/mcollective-filemgr-agent)
   * [NRPE Agent](https://github.com/puppetlabs/mcollective-nrpe-agent)
   * [Process Agent](https://github.com/puppetlabs/mcollective-process-agent)
   * [Net Test Agent](https://github.com/puppetlabs/mcollective-nettest-agent)
   * [Request auditing](http://docs.puppetlabs.com/mcollective/simplerpc/auditing.html) enabled and logging to /var/log/mcollective-audit.log

NRPE is installed on all machines with checks *check_load*, *check_disks* and
*check_swap*

The nodes all have a fact called *cluster* which distributed them into a number
of groups so you can play with the mcollective filters.  See *mco facts cluster*.

Additionally there will be a simple Puppet Master deployed on the _middleware_ node
which as its site.pp will use the file in _deploy/modules/puppet/files/site.pp_.
By default all this does is sleep a random period, enough to be able to test and
demo the MCollective Puppet Agent

Setup?
------

Assuming you have a working Vagrant setup on your system it should be real simple
to get going:

    $ git clone git://github.com/ripienaar/mcollective-vagrant.git
    $ cd mcollective-vagrant

You should now edit the Vagrantfile and adjust the constants at the top to your
tastes:

    $ vi Vagrantfile
    $ vagrant up

Using?
------

What follows is a whirlwind tour of MCollective where you can run these commands to
gain a sense of what it is about.

MCollective is a framework that you can use to solve your own orchestration problems
with, it provides addressing, networking, Authentication, Authorization and Auditing
for you leaving you to focus on just the problem you wish to solve.

The commands you'll see are all built ontop of the MCollective framework and it makes
it easy for you to build your own similar commands for your needs.  Puppet Labs provide
a bunch of mature plugins for common needs which you will see here.

At the end you will see a hint on the underlying structure of the RPC system and how
you can interact with it from scripts and other systems. Links to further reading is
at the end of the tour.

### Verifying it works

This is the most basic MCollective test, it broadcasts a message and shows you who
replies, you should see one _middleware_ machine and as many _node_ machines as you
set the _INSTANCES_ variable to:

    $ vagrant ssh middleware
    $ mco ping
    node0.example.net                        time=25.18 ms
    middleware.example.net                   time=26.50 ms

    ---- ping statistics ----
    2 replies max: 26.50 min: 25.18 avg: 25.84

### Selecting machines to communicate with

MCollective uses your Configuration Management system for addressing, as these machines
are built with Puppet you can use classes and facts for addressing.

Just the nodes with the roles::middleware class:

    $ mco ping -W roles::middleware

...and the roles::node

    $ mco ping -W roles::middleware

...and nodes that are middleware nodes with redis installed - matching based on
regular expressions:

    $ mco ping -W "roles::middleware /redis/"

There are a number of facts on each machine but as the nodes are identical there are
not much variance so we added a fact called _cluster_ that has some random data set:

    $ mco facts cluster
    Report for fact: cluster

            alfa                                    found 6 times
            bravo                                   found 5 times

    Finished processing 11 / 11 hosts in 49.67 ms

You can now combine this fact with Puppet Classes to pick a subset of your nodes, this
is an _AND_ search:

    $ mco ping -W "roles::node cluster=alfa"

...but you can do more complex things:

    $ mco ping -S "(roles::node or roles::middleware) and cluster=alfa"

These arguments tend to apply to most MCollective commands so any of the following commands
you'll see can be limited by the use of these discovery filters.

There are numerous other addressing methods - called discovery in MCollective - please
read the [MCollective CLI Usage](http://docs.puppetlabs.com/mcollective/reference/basic/basic_cli_usage.html)
documentation to see other ways.

### Getting information about a node

MCollective has a lot of information about your nodes, you can ask it to show you what it
knows with the _inventory_ command:

    $ mco inventory middleware.example.net
    Inventory for middleware.example.net:

       Server Statistics:
                          Version: 2.3.1
                       Start Time: Mon Feb 25 13:02:28 +0100 2013
                      Config File: /etc/mcollective/server.cfg
                      Collectives: mcollective
                  Main Collective: mcollective
                       Process ID: 3934
                   Total Messages: 4
          Messages Passed Filters: 3
                Messages Filtered: 1
                 Expired Messages: 0
                     Replies Sent: 2
             Total Processor Time: 1.46 seconds
                      System Time: 0.36 seconds

       Agents:
          discovery       filemgr         nettest
          nrpe            package         process
          puppet          rpcutil         service
          urltest

       Data Plugins:
          agent           fstat           nettest
          nrpe            package         process
          puppet          resource        service

       Configuration Management Classes:
          redis                          redis::config
          redis::install                 redis::service
          .
          .

       Facts:
          architecture => x86_64
          .
          .
          .

This is useful when debugging discovery issues or just to obtain information
about a specific node.

You can also use this command to build quick reports of your infrastructure and
remember the discovery filters you saw earlier can be used with this kind of
report to produce ones for subsets of nodes:

    $ mco inventory --script /etc/mcollective/inventory.mc

                Node Report Mon Feb 25 13:50:01 +0100

    Hostname:         Distribution:
    -------------------------------------------------------------------------

    node0.example.net Operating System: CentOS
                               Release: 6.3
                          Architecture: x86_64
                            Processors: 1
    .
    .
    .


See [Node Reports](http://docs.puppetlabs.com/mcollective/reference/ui/nodereports.html)
for more information on creating your own reports.

### Basic MCollective behaviour described

MCollective commands will try to only show you the most appropriate information. What this
means is if you tried to restart a service using MCollective it will not show you every
OK, it's only going to show you the cases where it could not complete your request:

    $ mco service restart nrpe
    Do you really want to operate on services unfiltered? (y/n): y

     * [ ============================================================> ] 11 / 11

       middleware.example.net: Could not restart service 'nrpe': Could not start Service[nrpe]: Execution of '/sbin/service nrpe start' returned 1:

    Finished processing 11 / 11 hosts in 1016.29 ms

Here you can see it discovered 11 nodes, acted on 11 nodes but 1 of the 11 failed
and it is only showing you the failure.

But when asking the status it assumes you actually want to see the information and so
shows it all with a short overview at the bottom of the most important information to
help you digest the information.

    $ mco service status nrpe

     * [ ============================================================> ] 11 / 11

            node2.example.net: running
            node4.example.net: running
            node6.example.net: running
            node0.example.net: running
            node5.example.net: running
            node9.example.net: running
            node3.example.net: running
            node8.example.net: running
       middleware.example.net: stopped
            node7.example.net: running
            node1.example.net: running

    Summary of Service Status:

       running = 10
       stopped = 1

    Finished processing 11 / 11 hosts in 174.97 ms

The progress bar is usually shown, this shows you the progress as nodes complete the
requested task, you can disable it using the *--np* or *--no-progress* arguments.

This is a key concept to understand in MCollective please see [this blog post](http://www.devco.net/archives/2010/08/28/effective_adhoc_commands_in_clusters.php)
for rationale and background.

### Managing Services

    $ mco package status mcollective

     * [ ============================================================> ] 2 / 2

            node0.example.net: mcollective-2.2.3-1.el6.noarch
       middleware.example.net: mcollective-2.2.3-1.el6.noarch

    Summary of Arch:

       noarch = 2

    Summary of Ensure:

       2.2.3-1.el6 = 2


    Finished processing 2 / 2 hosts in 523.95 ms

You can also use this to install, update and upgrade packages on the systems see
*mco package --help* for more information.

### Managing Packages

The package and service applications behave almost identical so I won't show full output
but you can stop, start, restart and obtain the status of any service.

    $ mco package status mcollective
    .
    .

See *mco service --help* for more information.

The *package* and *service* managers use the Puppet provider system to do their work so
they support any OS Puppet does.

### Testing network connectivity

You can easily if machines are able to reach another host using the nettest agent:

    $ mco nettest ping 192.168.2.10
    Do you really want to perform network tests unfiltered? (y/n): y

     * [ ============================================================> ] 11 / 11

    middleware.example.net                   time = 0.254
    node0.example.net                        time = 0.41

    Summary of RTT:

       Min: 0.254ms  Max: 1.316ms  Average: 0.577ms


    Finished processing 2 / 2 hosts in 49.83 ms

Similarly you can also test if a TCP connection can be made:

    $ mco nettest connect 192.168.2.10 8140

This command is best used with a discovery filter, imagine you suspect a machine in
some VLAN is down, you can run ask other machines in that cluster to test it's availability

   $ mco nettest ping 192.168.2.10 -W cluster=alfa --limit=20%

This will ask 20% of the machines in cluster=alfa to see if they can connect to the node
in question.

### Doing monitoring checks

This demo is setup with NRPE based monitoring and we integrated MCollective with NRPE.
You can thus easily obtain real time monitoring results:

    $ mco nrpe check_load

     * [ ============================================================> ] 11 / 11

    Summary of Exit Code:

               OK : 11
          WARNING : 0
         CRITICAL : 0
          UNKNOWN : 0


    Finished processing 11 / 11 hosts in 123.82 ms

### Network wide *pgrep*

You can quickly find out what nodes have processes matching some query much like the
Unix pgrep command:

    $ mco process list ruby

     * [ ============================================================> ] 2 / 2

       middleware.example.net

         PID      USER       VSZ            COMMAND
         2487     puppet     140.492 MB     /usr/bin/ruby /usr/bin/puppet master
         6451     root       160.797 MB     ruby /usr/sbin/mcollectived --pid=/var/run/mcollectived.pid

       node0.example.net

         PID      USER       VSZ            COMMAND
         6890     root       161.145 MB     ruby /usr/sbin/mcollectived --pid=/var/run/mcollectived.pid


    Summary of The Process List:

               Matched hosts: 2
           Matched Processes: 3
               Resident Size: 39.132 MB
                Virtual Size: 462.434 MB

    Finished processing 2 / 2 hosts in 82.51 ms

The fields shown are configurable - see [the process agent](https://github.com/puppetlabs/mcollective-process-agent)

### Testing website reachability

You can test the reachability of a website quite easily:

    $ mco urltest http://www.devco.net/

     * [ ============================================================> ] 2 / 2

          Tester Location DNS      Connect    Pre-xfer   Start-xfer Total      Bytes Fetched
              middleware: 5.0057   0.0031     0.1872     0.1871     5.4010     101859
                   node0: 5.0066   0.0043     0.1906     0.1905     5.4051     101859

    Summary:

          DNS lookup time: min: 5.0057 max: 5.0066 avg: 5.0062 sdev: 0.0006
         TCP connect time: min: 0.0031 max: 0.0043 avg: 0.0037 sdev: 0.0009
       Time to first byte: min: 0.1872 max: 0.1906 avg: 0.1889 sdev: 0.0024
       HTTP Responce time: min: 0.1871 max: 0.1905 avg: 0.1888 sdev: 0.0024
         Total time taken: min: 5.4010 max: 5.4051 avg: 5.4030 sdev: 0.0029

Here you can see DNS lookup time is a problem, my Vagrant machines tend to have DNS issues.

### Scripting and raw RPC

So far everything you have seen was purpose specific command line applications built to have
familiar behaviours for their purpose.  Every MCollective command though is simply performing
RPC requests to the network which provides these RPC end points.

The last command can be run by interacting with the RPC layer directly:

    $ mco rpc urltest perftest url=http://www.devco.net/

Here you can see you're using the *rpc application* to interact with the *urltest agent* calling
out to its *perftest action* and supplying the *url argument*.

The output will be familiar but now you can see it's more showing you raw data for every node
but still the basic behaviour and output format is familiar.

You can interact with any agent and to get a list of available agents run the *mco plugin doc*
command:

    $ mco plugin doc
    Please specify a plugin. Available plugins are:

    Agents:
      filemgr                   File Manager
      nettest                   Agent to do network tests from a mcollective host
      nrpe                      Agent to query NRPE commands via MCollective
      package                   Install and uninstall software packages
      process                   Agent To Manage Processes
      puppet                    Run Puppet agent, get its status, and enable/disable it
      rpcutil                   General helpful actions that expose stats and internals to SimpleRPC clients
      service                   Start and stop system services
      urltest                   Agent that connects to a URL and returns some statistics

And you can ask MCollective to show you available actions and arguments for each:

    $ mco plugin doc agent/urltest

This will produce auto generated help for the agent showing the available actions etc.

And finally you can easily write a small script to perform the same url test action:

    #!/usr/bin/ruby

    require 'mcollective'

    include MCollective::RPC

    tester = rpcclient("urltest")

    printrpc tester.perftest(:url => "http://www.devco.net/")

    printrpcstats

If you put this in a script and ran it you should see familiar output.

Further Reading?
---------------

Having seen some of the utility that MCollective provide you can now visit some of our other
documentation to learn how to get going and what it is about:

  * [Introduction](http://docs.puppetlabs.com/mcollective/)
  * [Terminology](http://docs.puppetlabs.com/mcollective/terminology.html)
  * [Using the CLI tools](http://docs.puppetlabs.com/mcollective/reference/basic/basic_cli_usage.html)
  * [Getting Started](http://docs.puppetlabs.com/mcollective/reference/basic/gettingstarted.html)
  * [Writing Agents](http://docs.puppetlabs.com/mcollective/simplerpc/agents.html)
  * [Writing Clients](http://docs.puppetlabs.com/mcollective/simplerpc/clients.html)

Modifying?
----------

The Puppet modules used to install the boxen are in the _deploy/modules_ directory.
The _mcollective_ module has _files/lib_ and everything in there will just be recursively
copied to the nodes.  So if you want to test some plugin you're working on just copy it
in there and run _vagrant provision_

The EPEL and Puppet Labs repositories are on the machines and all of the plugins mentioned
in the first section of this document are installed from there.  Some plugins though like
the Redis ones aren't yet available at Puppet Labs so for now they are deployed from the
module lib dir.

There is a package repo in _deploy/packages_ with some dependencies and this repo is
added to all the nodes, so if you drop a new package in there just run _createrepo_ in
that directory and it would be available to all the machines.

I'd love to see the various things like the Puppet setup done using proper modules from
the forge so PRs would be appreciated

Contact?
--------
R.I.Pienaar / rip@devco.net / @ripienaar / http://devco.net/
