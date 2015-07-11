//! @file Logger.cpp

#include "nasa_common_utilities/Logger.h"

using namespace std;
using namespace log4cpp;

namespace RCS
{
    Logger::Logger()
        : propertyFile("log4cpp.properties")
        , packagePath(ros::package::getPath("nasa_common_utilities"))
    {
        std::string localPropertyFile = "./" + propertyFile;

        try
        {
            PropertyConfigurator::configure(localPropertyFile);
        }
        catch (ConfigureFailure& e)
        {
            if (not (string(e.what()) == "File " + localPropertyFile + " does not exist"))
            {
                cerr << "WARN: Could not load local dir property file [" << localPropertyFile <<  "]: " << e.what() << endl;
            }

            std::string packagePropertyFile = packagePath + "/share/" + propertyFile;

            try
            {
                PropertyConfigurator::configure(packagePropertyFile);
            }
            catch (ConfigureFailure& e)
            {
                cerr << "WARN: Could not load package dir property file [" << packagePropertyFile <<  "]: " << e.what() << endl;

                Appender* rootAppender = new OstreamAppender("root", &cout);
                Layout* rootLayout = new BasicLayout();
                rootAppender->setLayout(rootLayout);
                Category::getRoot().addAppender(rootAppender);
                Category::getRoot().setPriority(Priority::WARN);

                Category::getRoot().log(Priority::WARN, "Could not load local dir or package dir property file: " + string(e.what()) + ". Using defaults of [std::out] and [WARN].");
            }
        }
    }

    Logger::~Logger()
    {
    }

    void Logger::log(const std::string& category, log4cpp::Priority::Value priority, const std::string& message)
    {
        getCategory(category).log(priority, message);
    }

    log4cpp::Category& Logger::getCategory(const std::string& category)
    {
        return Category::getInstance(category);
    }

    static Logger singleton;
}
