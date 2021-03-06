module Pronto
  class BitbucketServer < Bitbucket
    def pull_comments(sha)
      @comment_cache["#{pull_id}/#{sha}"] ||= begin
        client.pull_comments(slug, pull_id).inject([]) do |comments, comment|
          if comment['commentAnchor']
            comments << Comment.new(sha,
                                    comment['comment']['text'],
                                    comment['commentAnchor']['path'],
                                    comment['commentAnchor']['line'])
          end
        end
      end
    end

    private

    def client
      @client ||= BitbucketServerClient.new(@config.bitbucket_username,
                                            @config.bitbucket_password,
                                            @config.bitbucket_api_endpoint)
    end

    def pull
      @pull ||=
        if env_pull_id
          pull_requests.find { |pr| pr.id.to_i == env_pull_id.to_i }
        elsif @repo.branch
          pull_requests.find do |pr|
            pr['fromRef']['displayId'] == @repo.branch
          end
        end
    end
  end
end
