package dk.kb.mermeid.filter;

/**
 * <p>This a utility that generates application wide unique numeric IDs for
 * use in the NewFileServlet. It is using the singleton pattern to ensure that
 * time and a counter generates IDs that are indeed unique. The recipe for
 * this was found on the Internet.</p>
 */
public class IdGenerator {

    private static org.apache.log4j.Logger logger = 
	org.apache.log4j.Logger.getLogger(IdGenerator.class);

    private static int staticCounter;
    private final  int nBits=4;
    private static IdGenerator ourInstance = new IdGenerator();

    public static IdGenerator getInstance() {
        return ourInstance;
    }

    private IdGenerator () {
	this.staticCounter=0;
    }

    public java.lang.String getId() {
	long id = (System.currentTimeMillis() << nBits) | (staticCounter++ & 2^nBits-1);
	return "" + id;
    }

}
