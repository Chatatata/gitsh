require 'gitsh/colors'
require 'gitsh/prompt_color'

module Gitsh
  class Prompter
    DEFAULT_FORMAT = "%D %c%b%#%w".freeze

    def initialize(options={})
      @env = options.fetch(:env)
      @use_color = options.fetch(:color, true)
      @prompt_color = options.fetch(:prompt_color) { PromptColor.new(@env) }
      @options = options
    end

    def prompt
      padded_prompt_format.gsub(/%[bcdDw#]/, {
        '%b' => branch_name,
        '%c' => status_color,
        '%d' => Dir.getwd,
        '%D' => File.basename(Dir.getwd),
        '%w' => clear_color,
        '%#' => terminator
      })
    end

    private

    attr_reader :env, :prompt_color

    def padded_prompt_format
      "#{prompt_format.chomp} "
    end

    def prompt_format
      env.fetch('gitsh.prompt') { DEFAULT_FORMAT }
    end

    def branch_name
      if env.repo_initialized?
        env.repo_current_head
      else
        'uninitialized'
      end
    end

    def terminator
      if !env.repo_initialized?
        '!!'
      elsif env.repo_has_untracked_files?
        '!'
      elsif env.repo_has_modified_files?
        '&'
      else
        '@'
      end
    end

    def status_color
      if use_color?
        prompt_color.status_color
      else
        Colors::NONE
      end
    end

    def clear_color
      if use_color?
        Colors::CLEAR
      else
        Colors::NONE
      end
    end

    def use_color?
      @use_color
    end
  end
end
