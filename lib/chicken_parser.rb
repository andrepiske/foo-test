class ChickenParser
  def initialize(record_string)
    @record = JSON.parse(record_string, symbolize_names: true)
  end

  def modified_files
    @record[:commits].map { |commit| commit[:modified] }.flatten.uniq
  end

  def modified_commits_for_model
    model_regex = %r(\Aapp/models/(.*)\z)
    @record[:commits].map do |commit|
      commit if commit[:modified].any? { |file_name| file_name =~ model_regex }
    end.compact
  end
end
