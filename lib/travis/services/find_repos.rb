module Travis
  module Services
    class FindRepos < Base
      register :find_repos

      def run
        result
      end

      private

        def result
          @result ||= params[:ids] ? by_ids : by_params
        end

        def by_ids
          scope(:repository).where(:id => params[:ids])
        end

        def by_params
          scope = self.scope(:repository).recent
          scope = scope.by_member(params[:member])         if params[:member]
          scope = scope.by_owner_name(params[:owner_name]) if params[:owner_name]
          scope = scope.by_slug(params[:slug])             if params[:slug]
          scope = scope.search(params[:search])            if params[:search].present?

          if (params.keys & [:member, :owner_name, :search, :slug]).empty?
            # apply timeline scope only if it's default /repos request
            scope = scope.timeline
          end

          if params[:active]
            scope = scope.active
          elsif (params.keys & [:member, :owner_name, :search]).present?
            scope = scope.with_builds.order('last_build_started_at DESC NULLS FIRST')
          end

          scope
        end
    end
  end
end
