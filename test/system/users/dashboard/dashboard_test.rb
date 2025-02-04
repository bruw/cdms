require 'application_system_test_case'

class DashboardTest < ApplicationSystemTestCase
  context 'dashboard' do
    setup do
      @user = create(:user)
      login_as(@user, as: :user)
      @department = create(:department)
    end

    should 'display breadcrumbs' do
      visit users_root_path

      assert_selector '.breadcrumb-item', text: I18n.t('views.breadcrumbs.home')
    end

    should 'no documents available to sign' do
      document = create(:document, :certification, department: @department)
      create(:document_signer, document: document, user: @user)

      visit users_root_path

      assert_no_selector '#doc-sign-notification'
      assert_selector '#non-doc-sign div.h1', exact_text: '0'
      assert_selector '#non-doc-sign .text-muted', exact_text: I18n.t('activerecord.models.document_user.other')
    end

    should 'list documents available to sign' do
      documents_available = 3
      documents = create_list(:document, documents_available, :certification,
                              available_to_sign: true, department: @department)

      documents.each do |document|
        create(:document_signer, document: document, user: @user)
      end

      visit users_root_path

      within('#doc-sign-notification tbody') do
        documents.each_with_index do |document, index|
          child = index + 1
          base_selector = "tr:nth-child(#{child})"

          assert_selector base_selector, text: document.title
        end
      end
    end

    should 'display notification counter' do
      documents_available = 3
      documents = create_list(:document, documents_available, :certification,
                              available_to_sign: true, department: @department)
      documents.push(create(:document, :certification, department: @department))

      documents.each do |document|
        create(:document_signer, document: document, user: @user)
      end

      visit users_root_path

      assert_selector '#doc-sign-notification .notification-counter', exact_text: documents_available
    end
  end
end
