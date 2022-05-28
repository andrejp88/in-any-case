#!/usr/bin/env dub
/+ dub.sdl:
    name "test-watch"
    version "1.0.0"
    license "public domain"
    dependency "fswatch" version="~>0.5"
+/

import core.thread;
import fswatch;
import std.algorithm;
import std.array;
import std.datetime;
import std.process;


void main(string[] args)
{
    FileWatch sourceWatcher = FileWatch("source/", true);

    runTests(args);

    while (true)
    {
        auto sourceChanges = sourceWatcher.getEvents();

        if (sourceChanges.length > 0)
            runTests(args);

        Thread.sleep(500.msecs);
    }
}

void runTests(string[] args)
{
    Pid clearPid = spawnShell("clear");
    wait(clearPid);
    Pid dubTestPid = spawnProcess(["dub", "test", "--compiler=dmd", "--", "-t1"] ~ args[1..$]);
    wait(dubTestPid);
}
