# Rack::MiniProfiler

## Description

Rack::MiniProfiler is a piece of Rack middleware that injects profiling data into HTML responses. It is based on the mvc-mini-profiler project created by the StackOverflow team.

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