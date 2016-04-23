# Sidekick for Programmers

Run `cd node; make`

Build from IntelliJ build target (use Debug with JRebel).

Open `localhost:3000`

## Update plugin dependencies

Idea plugin depends on `lib_managed` which is updated when running `sbt update`.

    cd idea
    sbt update
