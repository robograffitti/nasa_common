#include <iostream>

#include <hayai/hayai.hpp>

#include <nasa_common_utilities/Logger.h>
#include <boost/lexical_cast.hpp>

class LoggingBenchmark : public Hayai::Fixture
{
protected:
    virtual void SetUp()
    {
        randInt = rand() % 1000 - 500;
        randDouble = rand() % 10000 / 1000. - 5.;
    }

    virtual void TearDown()
    {
    }

    int randInt;
    double randDouble;
    std::stringstream mStr;
    std::string mMsg;

    /// this is a prototype concept to improve the efficiency of logging
    template<class>
    class logMsgData;

    /// a log message - this is the class you use to build your message
    class logMsg
    {
    public:
        logMsg() : next(NULL)
        {
        }

        virtual ~logMsg()
        {
            /// cleanup
            if (next)
            {
                delete next;
                next = NULL;
            }
        }

        template <class T>
        logMsg& operator<<(const T& data)
        {
            /// add data to the log message
            // it is added to the end of the chain. If this is the end, we extend the chain
            if (next)
            {
                *next << data;
            }
            else
            {
                next = new logMsgData<T>(data);
            }
            return *this;
        }

        /// modify the output string
        // this is virtual so the data message can actually add the data
        virtual void out(std::string& output) const
        {
            if (next)
            {
                next->out(output);
            }
        }

    private:
        logMsg* next;
    };

    /// a log message - this is the class you use to build your message (another attempt)
    class logMsg2
    {
    public:
        logMsg2(const std::string& category, log4cpp::Priority::Value priority_in)
            : next(NULL)
            , cat(RCS::Logger::getCategory(category))
            , priority(priority_in)
            , isLogged(cat.isPriorityEnabled(priority))
        {
        }

        virtual ~logMsg2()
        {
            /// cleanup
            if (next)
            {
                delete next;
                next = NULL;
            }
        }

        template <class T>
        logMsg2& operator<<(const T& data)
        {
            /// add data to the log message
            if (!isLogged)
            {
                return *this;
            }

            // it is added to the end of the chain. If this is the end, we extend the chain
            if (next)
            {
                *next << data;
            }
            else
            {
                next = new logMsgData<T>(data);
            }
            return *this;
        }

        void log()
        {
            if (isLogged)
            {
                std::string str;
                out(str);
                cat.log(priority, str);
            }
        }

    protected:
        /// modify the output string
        // this is virtual so the data message can actually add the data
        virtual void out(std::string& output) const
        {
            if (next)
            {
                next->out(output);
            }
        }

    private:
        logMsg* next;
        log4cpp::Category& cat;
        log4cpp::Priority::Value priority;
        bool isLogged;
    };

    /// log message data holds the templated data in our log message chain
    template <class D>
    class logMsgData : public logMsg
    {
    public:
        logMsgData(const D& data_in) : logMsg(), data(data_in)
        {
        }

    protected:
        /// modify the output string with the actual data and then call parent::out to continue down the chain
        virtual void out(std::string& output) const
        {
            output += data;
            logMsg::out(output);
        }

        const D& data;
    };

    /// special logger
    class myLogger : public RCS::Logger
    {
    public:
        /// special log function takes logMsg, extracts data, and logs it
        static void log(const std::string& category, log4cpp::Priority::Value priority, const logMsg& message)
        {
            /// only extract the data if priority is appropriate
            log4cpp::Category& cat = getCategory(category);
            if (cat.isPriorityEnabled(priority))
            {
                std::string str;
                message.out(str);
                cat.log(priority, str);
            }
        }
    };
};

BENCHMARK_F(LoggingBenchmark, ErrorStringTest, 3, 10000)
{
    std::string msg = "test message: ";
    msg += boost::lexical_cast<std::string>(randInt);
    msg += " test int and double: ";
    msg += boost::lexical_cast<std::string>(randDouble);
    RCS::Logger::log("test category", log4cpp::Priority::ERROR, msg);
}

BENCHMARK_F(LoggingBenchmark, DebugStringTest, 3, 10000)
{
    std::string msg = "test message: ";
    msg += boost::lexical_cast<std::string>(randInt);
    msg += " test int and double: ";
    msg += boost::lexical_cast<std::string>(randDouble);
    RCS::Logger::log("test category", log4cpp::Priority::DEBUG, msg);
}

BENCHMARK_F(LoggingBenchmark, ErrorMemberStringTest, 3, 10000)
{
    mMsg = "test message: ";
    mMsg += boost::lexical_cast<std::string>(randInt);
    mMsg += " test int and double: ";
    mMsg += boost::lexical_cast<std::string>(randDouble);
    RCS::Logger::log("test category", log4cpp::Priority::ERROR, mMsg);
}

BENCHMARK_F(LoggingBenchmark, DebugMemberStringTest, 3, 10000)
{
    mMsg = "test message: ";
    mMsg += boost::lexical_cast<std::string>(randInt);
    mMsg += " test int and double: ";
    mMsg += boost::lexical_cast<std::string>(randDouble);
    RCS::Logger::log("test category", log4cpp::Priority::DEBUG, mMsg);
}

BENCHMARK_F(LoggingBenchmark, ErrorStringStreamTest, 3, 10000)
{
    std::stringstream str;
    str << "test message: " << randInt << " test int and double: " << randDouble;
    RCS::Logger::log("test category", log4cpp::Priority::ERROR, str.str());
}

BENCHMARK_F(LoggingBenchmark, DebugStringStreamTest, 3, 10000)
{
    std::stringstream str;
    str << "test message: " << randInt << " test int and double: " << randDouble;
    RCS::Logger::log("test category", log4cpp::Priority::DEBUG, str.str());
}

BENCHMARK_F(LoggingBenchmark, ErrorMemberStringStreamTest, 3, 10000)
{
    mStr.str("test message: ");
    mStr << randInt << " test int and double: " << randDouble;
    RCS::Logger::log("test category", log4cpp::Priority::ERROR, mStr.str());
}

BENCHMARK_F(LoggingBenchmark, DebugMemberStringStreamTest, 3, 10000)
{
    mStr.str("test message: ");
    mStr << randInt << " test int and double: " << randDouble;
    RCS::Logger::log("test category", log4cpp::Priority::DEBUG, mStr.str());
}

BENCHMARK_F(LoggingBenchmark, ErrorMyLoggerTest, 3, 10000)
{
    logMsg msg;
    msg << "test message: " << randInt << " test int and double: " << randDouble;
    myLogger::log("test category", log4cpp::Priority::ERROR, msg);
}

BENCHMARK_F(LoggingBenchmark, DebugMyLoggerTest, 3, 10000)
{
    logMsg msg;
    msg << "test message: " << randInt << " test int and double: " << randDouble;
    myLogger::log("test category", log4cpp::Priority::DEBUG, msg);
}

BENCHMARK_F(LoggingBenchmark, ErrorMyLogger2Test, 3, 10000)
{
    logMsg2 msg("test category", log4cpp::Priority::ERROR);
    msg << "test message: " << randInt << " test int and double: " << randDouble;
    msg.log();
}

BENCHMARK_F(LoggingBenchmark, DebugMyLogger2Test, 3, 10000)
{
    logMsg2 msg("test category", log4cpp::Priority::DEBUG);
    msg << "test message: " << randInt << " test int and double: " << randDouble;
    msg.log();
}

BENCHMARK_F(LoggingBenchmark, ErrorStreamTest, 3, 10000)
{
    RCS::Logger::getCategory("test category") << log4cpp::Priority::ERROR << "test message: " << randInt << " test int and double: " << randDouble;
}

BENCHMARK_F(LoggingBenchmark, DebugStreamTest, 3, 10000)
{
    RCS::Logger::getCategory("test category") << log4cpp::Priority::DEBUG << "test message: " << randInt << " test int and double: " << randDouble;
}

int main(int argc, char **argv) {
    Hayai::Benchmarker::RunAllTests();
    return 0;
}

