/**
 * @file Logger.h
 * @brief Defines the Logger classes.
 */

#ifndef LOGGER_H_
#define LOGGER_H_

#define PROPERTY_FILE "log4cpp.properties"
#define PROPERTY_PATH_LOCAL "./" PROPERTY_FILE

#ifdef BUILD_PREFIX
#   define PROPERTY_PATH_BUILD BUILD_PREFIX "/share/" PROPERTY_FILE
#endif //BUILD_PREFIX

#ifdef INSTALL_PREFIX
#   define PROPERTY_PATH_INSTALL INSTALL_PREFIX "/share/" PROPERTY_FILE
#endif //INSTALL_PREFIX

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
    };
}

#endif /* LOGGER_H_ */
