module AnalysisServices
  class BuildComments
    include Mandate

    initialize_with :comments_data

    def call
      return nil unless comments_data.size > 0

      intro + comments.join("\n\n---\n\n")
    end

    def comments
      repo = Git::WebsiteContent.head
      comments_data.map do |comment_data|
        template, params =
          if comment_data.is_a?(Hash)
            [ comment_data['comment'], (comment_data['params'] || {}).symbolize_keys ]
          else
            [comment_data, {}]
          end
        template_content = repo.automated_comment_for(template)
        raise "No template content for #{template}" if template_content.nil?
        template_content % params
      end
    end

    private

    def intro
      text = if comments_data.size == 1
          "Our analyzer detected that this point might be helpful for you."
        else
          "Our analyzer detected that these points might be helpful for you."
        end

      text + "\n\n---\n\n"
    end

  end
end
