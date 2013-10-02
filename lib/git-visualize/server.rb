# encoding: utf-8

module GitVisualize
  class Server < Sinatra::Base
    set :root, BASE_DIR
    @@mutex = Mutex.new

    get '/' do
      haml :index
    end

    # csv data for main table
    get '/rev_path_list.csv' do
      revision = params[:revision] or raise "params[:revision] is needed."
      execute_script("rev_path_list.rb #{Shellwords.escape(revision)}")
    end

    # used to sort
    get '/revs.csv' do
      revision = params[:revision] or raise "params[:revision] is needed."
      execute_script("revs.rb #{Shellwords.escape(revision)}")
    end

    # used to sort
    get '/dictionary_orderd_paths.csv' do
      revision = params[:revision] or raise "params[:revision] is needed."
      execute_script("dictionary_ordered_paths.rb #{Shellwords.escape(revision)}")
    end

    get '/js/main.js' do
      coffee :main
    end

    helpers do
      def execute_script(cmd)
        result = nil

        @@mutex.synchronize do
          Dir.chdir(TARGET_DIR) do
            statement = "ruby #{BASE_DIR}/scripts/#{cmd}"
            STDERR.puts "run '#{statement}' ..."
            STDERR.puts (result = `#{statement}`)
            STDERR.puts "========="
          end
        end

        result
      end
    end
  end
end

GitVisualize::Server.run! :host => 'localhost', :port => 9090
