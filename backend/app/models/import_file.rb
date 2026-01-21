class ImportFile < ApplicationRecord
  has_many :employee_feedbacks, dependent: :destroy

  validates :name, presence: true
  validate :must_be_csv_file

  def feedbacks_count
    employee_feedbacks.count
  end

  enum status: { processing: 0, completed: 1, failed: 2 }

  private

  def must_be_csv_file
    if name.present? && !name.downcase.end_with?('.csv')
      errors.add(:name, "deve ser um arquivo no formato CSV")
    end
  end
end