//! @file Logger.cpp

#include "nasa_common_utilities/Logger.h"

using namespace std;
using namespace log4cpp;

namespace RCS
{
    Logger::Logger()
    {
        try
        {
            PropertyConfigurator::configure(PROPERTY_PATH_LOCAL);
        }
        catch (ConfigureFailure& e)
        {
            if (not (string(e.what()) == "File "+string(PROPERTY_PATH_LOCAL)+" does not exist"))
            {
                cerr << "WARN: Could not load local dir property file [" << PROPERTY_PATH_LOCAL <<  "]: " << e.what() << endl;
            }
#ifdef BUILD_PREFIX
            try
            {
                PropertyConfigurator::configure(PROPERTY_PATH_BUILD);
            }
            catch (ConfigureFailure& e)
            {
                cerr << "WARN: Could not load local dir or build dir property file [" << PROPERTY_PATH_BUILD <<  "]: " << e.what() << endl;
#endif
#ifdef INSTALL_PREFIX
                try
                {
                    PropertyConfigurator::configure(PROPERTY_PATH_INSTALL);
                }
                catch (ConfigureFailure& e)
                {
#endif
                    Appender* rootAppender = new OstreamAppender("root", &cout);
                    Layout* rootLayout = new BasicLayout();
                    rootAppender->setLayout(rootLayout);
                    Category::getRoot().addAppender(rootAppender);
                    Category::getRoot().setPriority(Priority::WARN);

                    Category::getRoot().log(Priority::WARN, "Could not load local dir, build dir, or install dir property file ["+string(PROPERTY_PATH_INSTALL)+"]: "+string(e.what())+". Using defaults of [std::out] and [WARN].");
#ifdef INSTALL_PREFIX
                }
#endif
#ifdef BUILD_PREFIX
            }
#endif
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
