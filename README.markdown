# Rack::MiniProfiler

## Description

Rack middleware that injects profiling data into HTML responses. This project was inspired by StackOverflow's [mvc-mini-profiler](http://code.google.com/p/mvc-mini-profiler/).

## Features

To do...

## Using with Rails

Add the following line to your Gemfile

	gem "rack-mini_profiler"

Then add the following line to your application.rb file

	config.middleware.use "Rack::MiniProfiler"
	
## Configuration options

	Rack::MiniProfiler::Options.inject_jquery	# Default false
	Rack::MiniProfiler::Options.jquery_path # Default "https://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"