class Git::ExerciseReader
  attr_reader :repo, :exercise_slug, :commit, :config
  def initialize(repo, exercise_slug, commit, config)
    @repo = repo
    @exercise_slug = exercise_slug
    @commit = commit
    @config = config
  end

  def readme
    readme_ptr = exercise_tree['README.md']
    return nil if readme_ptr.nil?
    read_blob(readme_ptr[:oid], "")
  rescue => e
    puts e.message
    puts e.backtrace
    ""
  end

  def tests
    files = exercise_files.select { |f| f[:full].match(test_regexp) }
    test_suites = {}
    files.each do |file|
      name = file[:name]
      test_suites[name] = read_blob(file[:oid])
    end
    test_suites
  rescue => e
    puts "!!! #{e.message}"
    puts "!!! #{e.backtrace}"
    []
  end

  def solutions
    files = exercise_files(false).select { |f| f[:type] == :blob && f[:full].match(solution_regexp) }
    solutions = {}
    files.each do |file|
      name = file[:name]
      solution_text = read_blob(file[:oid])
      solutions[name] = solution_text unless solution_text.nil?
    end
    solutions || {}
  rescue => e
    puts e.message
    puts e.backtrace
    {}
  end

  def solution
    ss = solutions
    return "" if ss.empty?
    ss.first[1]
  end

  def blurb
    metadata_ptr = meta_tree["metadata.yml"]
    return nil if metadata_ptr.nil?
    metadata = repo.read_yaml_blob(metadata_ptr[:oid], {})
    metadata[:blurb]
  rescue => e
    puts e.message
    puts e.backtrace
    nil
  end

  def description
    desc_ptr = meta_tree["description.md"]
    return nil if desc_ptr.nil?
    read_blob(desc_ptr[:oid])
  rescue => e
    puts e.message
    puts e.backtrace
    nil
  end

  def files
    exercise_files.map do |file_defn|
      file_defn[:full]
    end
  end

  def read_file(path)
    files = exercise_files.map { |x| [x[:full], x[:oid]] }.flatten
    available_files = Hash[*files]
    return nil unless available_files.has_key?(path)
    read_blob(available_files[path])
  end

  private

  def meta_tree
    @meta_tree ||= begin
      meta_ptr = exercise_tree[".meta"]
      return {} if meta_ptr.nil?
      lookup(meta_ptr[:oid])
    end
  end

  def lookup(oid)
    repo.lookup(oid)
  end

  def read_blob(oid, default_value="")
    repo.read_blob(oid, default_value)
  end

  def test_pattern
    repo.test_pattern
  end

  def test_regexp
    repo.test_regexp
  end

  def solution_regexp
    repo.solution_regexp
  end

  def exercise_files(exclude_meta=true)
    @exercise_files ||= begin
      exercise_files = []
      exercise_tree.walk(:preorder) do |r, t|
        path = "#{r}#{t[:name]}"
        next if exclude_meta && path.start_with?(".meta")
        next if t[:type] == :tree
        t[:full] = path
        exercise_files.push(t)
      end
      exercise_files
    end
  end

  def tree
    commit.tree
  end

  def exercise_tree
    oid = tree['exercises'][:oid]
    t = lookup(oid)
    entry = t[exercise_slug]
    oid = entry[:oid]
    lookup(oid)
  end
end
