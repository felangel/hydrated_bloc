# benchmark

## Conditions
Benchmarks made on `Samsung Galaxy S9+`, 16 iterations per test.  
Bloc count is number of `storageTokens` used.  
State size represents how much raw data takes (dismissing expense on serialization).  
I.e for state of 1KB, list of 256 ints will be saved. Strings are saved as strings.  
AES is AES

## Index table

| Blocs 	| 4Bytes 	| 64Bytes 	| 256Bytes 	| 1KB 	| 4KB 	| 16KB 	| 1MB       	| 4MB 	|
|-------	|--------	|---------	|----------	|-----	|-----	|------	|-----------	|-----	|
| 1     	| +      	| +       	| +        	| +   	| +   	| +    	| +         	| +   	|
| 15    	| +      	| +       	| +        	| +   	| +   	| +    	| no single 	| -   	|
| 30    	| +      	| +       	| +        	| +   	| +   	| +    	| only hive 	| -   	|
| 75    	|        	|         	|          	| +   	|     	|      	|           	|     	|
| 150   	| +      	|         	| +        	|     	|     	|      	|           	|     	|