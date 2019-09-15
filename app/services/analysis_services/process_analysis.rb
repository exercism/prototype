module AnalysisServices
  class ProcessAnalysis
    include Mandate

    def initialize(iteration, ops_status, analysis)
      @iteration = iteration
      @ops_status = ops_status.to_s.to_sym
      @analysis = analysis.is_a?(Hash) ? analysis.symbolize_keys : {}
    end

    def call
      # If we don't have an analyser, then we should just
      # undo what we've done so far and leave this alone.
      if ops_status == :no_analyzer
        remove_system_lock
        return
      end

      create_database_record
      handle_analysis
      remove_system_lock

      record
    end

    private
    attr_reader :iteration, :ops_status, :analysis, :record

    def create_database_record
      @record = IterationAnalysis.create!(
        iteration: iteration,
        analysis: analysis,
        ops_status: ops_status,
        analysis_status: analysis[:status]
      )
    end

    def handle_analysis
      return unless solution.use_auto_analysis?
      return unless analysis_succeeded?

      case analysis[:status].to_s.to_sym
      when :approve,
           :approve_as_optimal # Legacy status to be removed EO July 2019

        post_comments
        Approve.(solution)
      else
        # We currently don't do anything with non-approved solutions
      end

    rescue => e
      record.update!(website_error: e.message)
    end

    def remove_system_lock
      UnlockSolution.(solution)
    end

    def analysis_succeeded?
      ops_status == :success
    end

    # This method will raise exceptions if
    # comments are missing or invalid.
    def post_comments
      comments_data = analysis[:comments]

      return unless comments_data.present?
      return unless comments_data.is_a?(Array)

      comments = BuildComments.(comments_data)
      PostComments.(iteration, comments)
    end

    memoize
    def solution
      iteration.solution
    end

    memoize

    def system_user
      User.system_user
    end
  end
end
