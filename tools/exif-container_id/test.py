import exifcontainer
import numpy as np
import pandas as pd
print("Expect unique:")
df = pd.DataFrame(np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]]),
	columns=['a', 'b', 'c'])
exifcontainer.check_unique(df)
print("Good")
print("Expect not unique:")
df = pd.DataFrame(np.array([[1, 2, 3], [4, 5, 6], [7, 8, 3]]),
	columns=['a', 'b', 'c'])
exifcontainer.check_unique(df)