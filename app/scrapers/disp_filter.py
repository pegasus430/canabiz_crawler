class  DispensaryFilter(object):
    def __init__(self, state_names, city_low_limit = 'A', city_upper_limit = 'Z'):
        self._state_names = self._get_valid_states(state_names)
        self._city_first_letter_range = self._get_city_first_letter_range(city_low_limit, city_upper_limit)

    def get_state_names(self):
        return self._state_names
    
    def match_city(self, disp_city_name):
        if len(disp_city_name) > 0:
            return ord(disp_city_name[0]) in self._city_first_letter_range
        return False

    def _get_city_first_letter_range(self, city_low_limit, city_upper_limit):
        l = city_low_limit.upper() if city_low_limit else 'A'
        r = city_upper_limit.upper() if city_upper_limit else 'Z'

        if l >= 'A' and r <= 'Z' and r > l:
            return range(ord(l), ord(r) + 1)
        return range(ord('A'), ord('Z') + 1)
    
    def _get_valid_states(self, state_names):
        return [ sn.lower() for sn in state_names if state_names != '']
        
def get_city_limits(text):
    split = text.split('=')
    if not split or len(split) < 2:
        return 'A', 'Z'
    
    letters = split[1].split('-')
    if not letters or len(letters) < 2:
        return 'A', 'Z'
    
    return letters[0], letters[1]

def get_dispensary_filter(arr):
    if arr and len(arr) > 1:
        last_arg = arr[len(arr) - 1]
        if '=' in last_arg:
            l,r = get_city_limits(last_arg)
            state_names = arr[:len(arr) - 1]
            return DispensaryFilter(state_names, l, r)
    return DispensaryFilter(arr)
