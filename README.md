# Frequency Text Analysis Toolkit
## A program to analyze the frequency of words within a text and to put the Pareto Principle to the test.

#### What is the Pareto Principle?
The Pareto Principle states that roughly 80% of the effects come from 20% of the causes. In the case of word frequency, it would mean that the top 20% of words in a text (sorted by frequency), make up roughly 80% of the text. This program is designed to test the principle with real world texts in addition to providing tools to analyze word frequencies. 

#### In particular, this program can: tally the frequency of words in a text, list words compromising the top 20% frequently used words, and test whether the Pareto Principle applies to a text within a margin of error. 

### Set Up
- Install DrRacket from https://download.racket-lang.org/.
- Open frequency-analysis.rkt. 
- This program depends on the loudhum library. Install this package using the github link: https://github.com/grinnell-cs/loudhum, making sure that the dependecny mode is set to auto or ask. 
The program is now ready to be used!

### Use
Each promiment function is designed to take a file (in the format of a string) as input. You can analyze any text file you wish so long as it is converted to a string using 'file->string'. As an example, the first chapter of *The Picture of Dorian Gray* by Oscar Wilde (https://www.gutenberg.org/ebooks/4078) is provided and defined as 'dorian' within the program. Many free books are on the Project Gutenberg site for those who are interested. 

- Use 'frequency-tally' to determine how often each word appears in a text.
- Use 'take20%' if you wish to see the top 20% of words in a text by frequency or the total summation of appearances for the top 20% of words.
- Use 'pareto?' to determine if a text follows the Pareto Principle within a specified margin of error (99, 95, or 90). This tests whether the top 20% of words in a text make up roughly 80% (no greater and no less) of the text.

#### My Findings
After applying testing the Pareto Principle to multiple texts, I found that even though the 80-20 ratio is common, it is not a mathematically fixed distrubution. Smaller sample sizes were more likely to fall below 80% and neared ratios like 70-20, even for texts as short as two pages! For larger samples, the percentage was frequently above 80% and nearing ratios like 90-20. For example, the first chapter of Dorian Gray had 95%! Despite how many unique words we use, language is repetitive. Looking at the top 20% of words, we see that across all texts, the most frequent words are filler and sentence building words such as "the", "be", "and", "of", and "a". Conversly, the least frequently used words were more likely to be context words such as in Dorian Gray: "pain", "rubbish", "smoking", "odor", and "imprison". Overall, I have found that the 80-20 ratio of the Pareto Principle is not as widely applicable as it seemed, but the core idea that a wide portion of the whole is made up of smaller amount of causes is applicable from texts as short as 2 pages to entire books.

