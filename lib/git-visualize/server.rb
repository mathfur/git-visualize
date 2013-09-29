# encoding: utf-8

module GitVisualize
  class Server < Sinatra::Base


    # csv data for main table
    get '/rev_list.csv' do
      revision = params[:revision] or raise "params[:revision] is needed."
      execute_script("rev_path_list.rb -- #{Shellwords.escape(revision)}")
    end

    # used to sort
    get '/x_order' do
      `ruby scripts/rev_path_list.rb`
    end

    # used to sort
    get '/y_order' do
      # y_order.csvを返す
    end

    helper do
      def execute_script(cmd)
        Dir.chdir(TARGET_DIR) do
          statement = "ruby #{BASE_DIR}/scripts/#{cmd}"
          STDERR.puts "run '#{statement}' ..."
          result = shell(statement)
          STDERR.puts "run '#{statement}' ..."
        end

        result
      end
    end
  end
end

GitVisualize::Server.run! :host => 'localhost', :port => 9090
