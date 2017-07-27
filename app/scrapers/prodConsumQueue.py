from Queue import Queue
from collections import deque

class ProdComsumQueue(Queue):
# class ProdComsumQueue(deque):
	def __init__(self, size):
		# super(ProdComsumQueue, self).__init__(size)
		Queue.__init__(self, size)
		self.populated = False

	def was_populated(self):
		return self.populated

	def put(self, item):
		self.populated = True
		Queue.put(self, item)
