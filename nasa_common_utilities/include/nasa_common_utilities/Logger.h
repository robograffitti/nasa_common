/**
 * @file Logger.h
 * @brief Defines the Logger classes.
 */

#ifndef LOGGER_H_
#define LOGGER_H_

#include <ros/package.h>
#include <log4cpp/PropertyConfigurator.hh>
#include <log4cpp/Category.hh>
#include <log4cpp/Appender.hh>
#include <log4cpp/OstreamAppender.hh>

namespace RCS  // Robot Control System
{
    class Logger
    {
    public:
        Logger();
        virtual ~Logger();

        static void log(const std::string& category, log4cpp::Priority::Value priority, const std::string& message);
        static log4cpp::Category& getCategory(const std::string& category);
    private:
        std::string propertyFile;
        std::string packagePath;
    };
}

#endif /* LOGGER_H_ */
