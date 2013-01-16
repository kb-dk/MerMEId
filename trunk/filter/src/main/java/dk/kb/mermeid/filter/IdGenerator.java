package dk.kb.mermeid.filter;

/**
 * <p>This a utility that generates application wide unique numeric IDs for
 * use in the NewFileServlet. It is using the singleton pattern to ensure that
 * at each time the generated IDs are unique.</p>
 */
public class IdGenerator {

    private static org.apache.log4j.Logger logger = 
	org.apache.log4j.Logger.getLogger(IdGenerator.class);

    private static int staticCounter;
    private final  int nBits=4;
    private static IdGenerator ourInstance = new IdGenerator();

    /**
     * <p>We return ourselves to whom it might concern</p>
     * @return an IdGenerator instance
     */
    public static IdGenerator getInstance() {
        return ourInstance;
    }

    /**
     * <p>The Constructor. We keep track of how many times we have been called
     * at any moment of our existence. We reset the counter in the
     * constructor.</p>
     */
    private IdGenerator () {
	this.staticCounter=0;
    }

    /**
     * <p>Here we calculate the ID as a java.lang.Long, and return it as a string</p>
     *
     * @return an ID which is unique application wide as a string
     */
    public java.lang.String getId() {
	long id = (System.currentTimeMillis() << nBits) | (staticCounter++ & 2^nBits-1);
	return "" + id;
    }

}
