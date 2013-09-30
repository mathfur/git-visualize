require 'getoptlong'
require 'fileutils'
require "active_support/core_ext"
require "sinatra"
require "shellwords"
require 'coffee-script'

require "git-visualize/version"
require "git-visualize/helper"

BASE_DIR = "#{File.dirname(__FILE__)}/.."
TARGET_DIR = Dir.pwd
