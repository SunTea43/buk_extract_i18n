describe TextProcessor do
  let(:processor) { TextProcessor.new }

  it 'returns a valid summary for a given text' do
    text = "Un texto largo de ejemplo..."
    summary = processor.key_summary(text)
    expect(summary).not_to be_empty
    expect(summary.length).to be < text.length
  end

  it 'transforms summary to a valid key' do
    summary = "Un resumen de ejemplo"
    key = processor.key_summary(summary)
    expect(key).not_to include(' ')
    expect(key).to eq "un_resumen_de_ejemplo"
  end
end
