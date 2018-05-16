module ApplicationHelper
	#method will help with the sorting of admin table records
    def sortable(column, title = nil)
        title ||= column.titleize
        direction = column == params[:sort] && params[:direction] == 'asc' ? 'desc' : 'asc'
        link_to title, :sort => column, :direction => direction
    end
  
  def produce_unit_methods
    ['1 gram','1 Eighth','Half Ounce']
  end
  
end
