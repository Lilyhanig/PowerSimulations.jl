using PowerGraphics
using Plots
using PlotlyJS
const PG = PowerGraphics
include("../../src/fake_data.jl")
# # How to Make a report

# See [How to set up plots](set_up_plots.md) to get started

# ### Set up a report template
# In [report_templates](report_templates) there are templates that can be copied and re-named to make a report.

design_template = "generic_report_design.jmd"

# Generate report

# The report can be generated as a LaTeX PDF (default) or an html file,
# to set the document type as HTML, use the key word argument `doctype = "md2html"`

out_path = "Generated_Reports/"
#PG.report(results, out_path, design_template; doctype = "md2html")

# creates an HTML

res = "fake resuts"
out_path = "Generated_Reports/"
#PG.report(results, out_path, design_template)

# creates a PDF
