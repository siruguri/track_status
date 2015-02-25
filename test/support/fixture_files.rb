module FixtureFiles
  def fixture_file(filename)
    open(File.join(Rails.root, 'test', 'fixtures', 'files', filename)).readlines.join ''
  end
end
