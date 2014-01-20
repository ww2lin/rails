require 'cases/helper'
require 'models/book'

class EnumTest < ActiveRecord::TestCase
  fixtures :books

  setup do
    @book = books(:awdr)
  end

  test "query state by predicate" do
    assert @book.proposed?
    assert_not @book.written?
    assert_not @book.published?

    assert @book.unread?
  end

  test "query state with strings" do
    assert_equal "proposed", @book.status
    assert_equal "unread", @book.read_status
  end

  test "find via scope" do
    assert_equal @book, Book.proposed.first
    assert_equal @book, Book.unread.first
  end

  test "update by declaration" do
    @book.written!
    assert @book.written?
  end

  test "update by setter" do
    @book.update! status: :written
    assert @book.written?
  end

  test "enum methods are overwritable" do
    assert_equal "do publish work...", @book.published!
    assert @book.published?
  end

  test "direct assignment" do
    @book.status = :written
    assert @book.written?
  end

  test "assign string value" do
    @book.status = "written"
    assert @book.written?
  end

  test "enum changed attributes" do
    old_status = @book.status
    @book.status = :published
    assert_equal old_status, @book.changed_attributes[:status]
  end

  test "enum changes" do
    old_status = @book.status
    @book.status = :published
    assert_equal [old_status, 'published'], @book.changes[:status]
  end

  test "enum attribute was" do
    old_status = @book.status
    @book.status = :published
    assert_equal old_status, @book.attribute_was(:status)
  end

  test "enum attribute changed" do
    @book.status = :published
    assert @book.attribute_changed?(:status)
  end

  test "enum attribute changed to" do
    @book.status = :published
    assert @book.attribute_changed?(:status, to: 'published')
  end

  test "enum attribute changed from" do
    old_status = @book.status
    @book.status = :published
    assert @book.attribute_changed?(:status, from: old_status)
  end

  test "enum attribute changed from old status to new status" do
    old_status = @book.status
    @book.status = :published
    assert @book.attribute_changed?(:status, from: old_status, to: 'published')
  end

  test "assign non existing value raises an error" do
    e = assert_raises(ArgumentError) do
      @book.status = :unknown
    end
    assert_equal "'unknown' is not a valid status", e.message
  end

  test "assign nil value" do
    @book.status = nil
    assert @book.status.nil?
  end

  test "assign empty string value" do
    @book.status = ''
    assert @book.status.nil?
  end

  test "assign long empty string value" do
    @book.status = '   '
    assert @book.status.nil?
  end

  test "constant to access the mapping" do
    assert_equal 0, Book.statuses[:proposed]
    assert_equal 1, Book.statuses["written"]
    assert_equal 2, Book.statuses[:published]
  end

  test "building new objects with enum scopes" do
    assert Book.written.build.written?
    assert Book.read.build.read?
  end

  test "creating new objects with enum scopes" do
    assert Book.written.create.written?
    assert Book.read.create.read?
  end

  test "_before_type_cast returns the enum label (required for form fields)" do
    assert_equal "proposed", @book.status_before_type_cast
  end
end
