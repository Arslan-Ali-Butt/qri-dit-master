class MultitenancyMiddleware < ThinkingSphinx::Middlewares::Middleware
  def call(contexts)
    contexts.each do |context|
      Inner.new(context).call
    end

    app.call contexts
  end

  class Inner
    def initialize(context)
      @context = context
    end

    def call
      tenant = options[:tenant]
      return unless tenant

      classes = options[:classes] || []
      indices = options[:indices] || []

      set = ThinkingSphinx::IndexSet.new(classes, indices)
      options[:classes] = []
      options[:indices] = set.select { |index|
        index.name[/_#{tenant}_(core|delta)$/]
      }.map(&:name)
    end

    private

    def options
      @context.search.options
    end
  end
end
